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
    ".config/rofi/oneDarkPro.rasi".source = ./rofi/oneDarkPro.rasi;

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
    nodejs
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
      background = "#1e1e1e";
      foreground = "#abb2bf";
      cursor = "#61afef";
      cursor_text_color = "#1e1e1e";

      selection_background = "#094771";
      selection_foreground = "#abb2bf";

      color0 = "#3f4451";
      color8 = "#4f5666";
      color1 = "#e06c75";
      color9 = "#e06c75";
      color2 = "#98c379";
      color10 = "#98c379";
      color3 = "#e5c07b";
      color11 = "#e5c07b";
      color4 = "#61afef";
      color12 = "#61afef";
      color5 = "#c678dd";
      color13 = "#c678dd";
      color6 = "#56b6c2";
      color14 = "#56b6c2";
      color7 = "#828997";
      color15 = "#abb2bf";
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
