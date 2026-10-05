{ pkgs, ... }:
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
