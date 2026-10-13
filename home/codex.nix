{ config, pkgs, ... }:
let
  codexNotify = pkgs.writeShellScript "codex-desktop-notify" ''
    payload=$(cat)
    event=$(${pkgs.jq}/bin/jq -r '.hook_event_name' <<< "$payload")
    project=$(${pkgs.jq}/bin/jq -r '.cwd | rtrimstr("/") | split("/") | last | if . == null or . == "" then "/" else . end' <<< "$payload")
    case "$event" in
      Stop) title="Codex — Turn finished"; detail="Turn finished." ;;
      PermissionRequest) title="Codex — Permission requested"; detail="Permission requested." ;;
      *) exit 0 ;;
    esac
    project=$(${pkgs.jq}/bin/jq -nr --arg value "$project" '$value | @html')
    ${pkgs.libnotify}/bin/notify-send --app-name=Codex --urgency=normal -- "$title" "$project: $detail" >&2 || true
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

  # Mutable engineering skills live in dev-config, like the existing three.
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

  # Native Codex CLI hooks. Review both with /hooks after activation.
  # Keep mutable config.toml (including existing plugin trust) unmanaged.
  home.file.".codex/hooks.json".text = builtins.toJSON {
    hooks = builtins.listToAttrs (
      map
        (event: {
          name = event;
          value = [
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
        })
        [
          "Stop"
          "PermissionRequest"
        ]
    );
  };
}
