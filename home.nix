{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  home.username = "edtosoy";
  home.homeDirectory = "/home/edtosoy";
  home.stateVersion = "25.11";
  #################################
  # Dotfiles
  #################################
  home.file = {

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
    "$HOME/.local/share/pnpm"
  ];
  #################################
  # User Packages
  #################################
  home.packages = with pkgs; [
    # terminals
    kitty
    bat
    eza
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
    wl-clipboard
    grim # for screenshots
    slurp # for region selection
    satty
    # CLI
    ripgrep
    fd
    fzf
    gnumake
    gcc
    tree-sitter
    # media
    playerctl
    discord
    # dev
    nodejs_24
    yarn
    pnpm
    python3
    python3Packages.pip
    python3Packages.virtualenv
    uv
    tmux
    pkgs-unstable.bruno
    openssl
    firefox-devedition
    # network
    protonvpn-gui
    # neovim LSP
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # html, cssls, eslint
    nodePackages."@tailwindcss/language-server"
    emmet-language-server
    angular-language-server
    nil # nil_ls
    lua-language-server
    prettierd
    stylua
  ];
  #################################
  # Cursor
  #################################
  home.pointerCursor =
    let
      getFrom = url: hash: name: {
        gtk.enable = true;
        name = name;
        size = 36;
        package = pkgs.runCommand "moveUp" { } ''
          mkdir -p $out/share/icons
          ln -s ${
            pkgs.fetchzip {
              url = url;
              hash = hash;
            }
          } $out/share/icons/${name}
        '';
      };
    in
    getFrom "https://github.com/dreamsofautonomy/banana-cursor/releases/download/v2.2.0/Banana.tar.xz"
      "sha256-FA7iKldiuvWizVcrbANGAKgtQ3r/7nQovn2Lk+utvIU="
      "Banana";
  home.sessionVariables = {
    XCURSOR_THEME = "Banana";
    XCURSOR_SIZE = "36";
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };
  #################################
  # GTK / Qt
  #################################
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Banana";
      size = 36;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
  #################################
  # Shell
  #################################
  programs.bash = {
    enable = true;
    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    bashrcExtra = ''
      prisma() {
        nix-shell -p prisma_7 --run "prisma $*"
      }
    '';
    shellAliases = {
      btw = "echo I use nixos, btw";
      # NixOS
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-setup#nixos-btw";
      hms = "home-manager switch --flake ~/nixos-setup#nixos-btw";
      nix-clean = "sudo nix-collect-garbage -d";

      # Git
      ## Basic workflow
      gs = "git status";
      ga = "git add .";
      gc = "git commit -m";
      gp = "git push";
      gl = "git pull";
      gf = "git fetch";
      glo = "git log --oneline --graph --decorate";
      ## Branch
      gb = "git branch";
      gco = "git checkout";
      gcb = "git checkout -b";
      ## Rebase
      grb = "git rebase";
      grbi = "git rebase -i";
      grc = "git rebase --continue";
      gra = "git rebase --abort";
      ## Cherry-pick & revert
      gcp = "git cherry-pick";
      grev = "git revert";
      ## Reset & recovery
      grs = "git reset --soft HEAD~1";
      grl = "git reflog";
      ## Stash
      gst = "git stash";
      gstm = "git stash -m";
      gstp = "git stash pop";
      gstl = "git stash list";
      ## Worktree
      gwta = "git worktree add";
      gwtl = "git worktree list";
      gwtr = "git worktree remove";
      ## Bisect
      gbs = "git bisect start";
      gbsg = "git bisect good";
      gbsb = "git bisect bad";
      gbsr = "git bisect reset";
      ## Inspect
      grm = "git remote";
      gd = "git diff";
      gsh = "git show";
      gcf = "git cat-file -p";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      # Dev
      v = "nvim";
      grep = "rg";
      cat = "bat";
      ls = "eza --icons";
      ll = "eza -al --icons";
      la = "eza -A --icons";
      ng = "npx @angular/cli@latest";
      ts = "tmux-sessionizer";
    };
  };

  #################################
  # NeoVim
  #################################
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
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
