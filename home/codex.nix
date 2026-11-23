{ config, pkgs, ... }:
let
  codexNotify = pkgs.writeShellScript "codex-desktop-notify" ''
      payload=$(cat)

      event=$(${pkgs.jq}/bin/jq -er '.hook_event_name // empty' <<< "$payload") || exit 0

      # Only notify when a Codex turn finishes.
      [ "$event" = "Stop" ] || exit 0

      project=$(${pkgs.jq}/bin/jq -r '
        (.cwd // "")
        | rtrimstr("/")
        | split("/")
        | last
        | if . == null or . == "" then "/" else . end
        | @html
      ' <<< "$payload")

      detail=$(${pkgs.jq}/bin/jq -r '
        (.last_assistant_message // "")
        | gsub("[[:space:]]+"; " ")
        | .[0:150]
        | if . == "" then "Turn finished." else . end
        | @html
      ' <<< "$payload")

      model=$(${pkgs.jq}/bin/jq -r '
        (.model // "")
        | ascii_upcase
        | @html
      ' <<< "$payload")

      status="✅ Turn finished"
      if [ -n "$model" ]; then
        status="$status — $model"
      fi

      ${pkgs.libnotify}/bin/notify-send \
        --app-name=Codex \
        --urgency=normal \
        -- "Codex — $project" "<b>$status</b>

    $detail" >&2 || true

      printf '{}\n'
  '';
in
{
  # OAuth needs encrypted Secret Service storage; do not add an SSH agent here.
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # Sway's session bus needs the password prompt as well as the secrets daemon.
  home.file.".local/share/dbus-1/services/org.gnome.keyring.SystemPrompter.service".source =
    "${pkgs.gcr}/share/dbus-1/services/org.gnome.keyring.SystemPrompter.service";

  # Mutable engineering skills live in dev-config.
  home.file.".agents/skills/visual-iterate".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev-config/skills/visual-iterate";
  home.file.".agents/skills/trace-source".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev-config/skills/trace-source";
  home.file.".agents/skills/prepare-pr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev-config/skills/prepare-pr";

  home.file.".local/bin/codex-browser" = {
    source = ../scripts/codex-browser.mjs;
    executable = true;
  };

  home.file.".local/bin/codex-service" = {
    source = ../scripts/codex-service.py;
    executable = true;
  };

  home.file.".config/codex/services.json".source = ../config/codex-services.json;

  # Native Codex CLI Stop hook. Verify with /hooks after activation.
  # Keep mutable config.toml (including existing plugin trust) unmanaged.
  home.file.".codex/hooks.json".text = builtins.toJSON {
    hooks.Stop = [
      {
        hooks = [
          {
            type = "command";
            command = "${codexNotify}";
            timeout = 3;
          }
        ];
      }
    ];
  };
}
