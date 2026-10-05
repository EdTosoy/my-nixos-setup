{
  pkgs,
  pkgs-unstable,
  ...
}:
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
  imports = [
    ./home/desktop.nix
    ./home/shell.nix
    ./rofi/rofi.nix
  ];

  home.username = "edtosoy";
  home.homeDirectory = "/home/edtosoy";
  home.stateVersion = "26.05";
  #################################
  # Dotfiles
  #################################
  home.file = {

    # Native Codex CLI 0.160.0 hooks. Review both with /hooks after activation.
    # Keep mutable config.toml (including existing plugin trust) unmanaged.
    ".codex/hooks.json".text = builtins.toJSON {
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

    ".config/sway".source = ./sway;
    ".config/nvim".source = ./nvim;
    ".config/tmux/tmux.conf".source = ./tmux/tmux.conf;
    ".config/qutebrowser/config.py".source = ./qutebrowser/config.py;
    ".config/qutebrowser/greasemonkey".source = ./qutebrowser/greasemonkey;
    ".config/qutebrowser/styles".source = ./qutebrowser/styles;
    ".config/rofi/config.rasi".source = ./rofi/config.rasi;
    ".config/rofi/theme.rasi".source = ./rofi/theme.rasi;

    ".local/bin/tmux-sessionizer" = {
      source = ./scripts/tmux-sessionizer;
      executable = true;
    };

  };
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  #################################
  # User Packages
  #################################
  home.packages = with pkgs; [
    # applications
    pkgs-unstable.zoom-us
    codex

    # terminals
    kitty

    # browsers
    qutebrowser
    chromium

    # WM tooling
    rofi
    dunst
    libnotify
    swaybg
    swayidle
    swaylock

    # file management
    yazi
    grim # for screenshots
    slurp # for region selection
    satty
    zip

    # CLI
    eza
    ripgrep
    fd
    fzf
    gnumake
    gcc
    tree-sitter
    jq
    wl-clipboard
    lsof

    # media
    playerctl

    # dev
    nodejs_24
    pnpm
    uv
    tmux
    bubblewrap
    bruno
    openssl
    nest-cli
    prettierd
    stylua
    ansible
    ansible-lint
    gh
    python312
    basedpyright
    ruff

    # cloud / infra
    terraform
    kubectl
    k9s
    awscli2
    azure-cli

    # neovim LSP
    terraform-ls
    prisma-language-server
    typescript
    typescript-language-server
    vscode-langservers-extracted
    tailwindcss-language-server
    emmet-language-server
    prisma
    pkgs-unstable.angular-language-server
    nil
    lua-language-server
    gopls
    dockerfile-language-server
    docker-compose-language-service
    yaml-language-server
    marksman
    bash-language-server
    shellcheck
    basedpyright
    ruff

  ];
  home.sessionVariables = {
    XCURSOR_THEME = "Banana";
    XCURSOR_SIZE = "36";
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };

  #################################
  # NeoVim
  #################################
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = true;
    withPython3 = true;
  };

  #################################
  # Kitty
  #################################
  programs.kitty = {
    enable = true;
    settings = {
      background = "#22272e";
      foreground = "#adbac7";

      cursor = "#539bf5";
      cursor_text_color = "#22272e";

      selection_background = "#264466";
      selection_foreground = "#cdd9e5";

      color0 = "#1c2128";
      color8 = "#444c56";

      color1 = "#f47067";
      color9 = "#ff938a";

      color2 = "#57ab5a";
      color10 = "#6bc46d";

      color3 = "#daaa3f";
      color11 = "#eac55f";

      color4 = "#539bf5";
      color12 = "#6cb6ff";

      color5 = "#986ee2";
      color13 = "#b083f0";

      color6 = "#39c5cf";
      color14 = "#56d4dd";

      color7 = "#909dab";
      color15 = "#cdd9e5";

      active_border_color = "#539bf5";
      inactive_border_color = "#444c56";

      tab_bar_background = "#1c2128";
      active_tab_background = "#22272e";
      inactive_tab_background = "#1c2128";

      active_tab_foreground = "#cdd9e5";
      inactive_tab_foreground = "#768390";
    };
  };

  #################################
  # Git
  #################################
  programs.git = {
    enable = true;
    settings = {
      user.name = "EdTosoy";
      user.email = "68400105+EdTosoy@users.noreply.github.com";
      rerere.enabled = true;
    };
  };
}
