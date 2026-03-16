{ config, pkgs, pkgs-unstable, ... }:
{
  home.username = "johncarlojose";
  home.homeDirectory = "/home/johncarlojose";
  home.stateVersion = "25.11";
  #################################
  # Dotfiles
  #################################
  home.file = {
    ".config/sway/config".source                = ./sway/config;
    ".config/qtile/config.py".source            = ./qtile/config.py;  # kept for reference
    ".config/qutebrowser/config.py".source      = ./qutebrowser/config.py;
    ".config/qutebrowser/greasemonkey".source   = ./qutebrowser/greasemonkey;
    ".config/qutebrowser/styles".source         = ./qutebrowser/styles;
    ".config/rofi/config.rasi".source           = ./rofi/config.rasi;
    ".config/rofi/oneDarkPro.rasi".source       = ./rofi/oneDarkPro.rasi;
    ".config/Code/User/keybindings.json".source = ./vscode/keybindings.json;
    ".config/Code/User/settings.json" = {
      text = builtins.toJSON (
        builtins.fromJSON (builtins.readFile ./vscode/settings.json) // {
          "vscode-neovim.neovimExecutablePaths.linux" =
            "/etc/profiles/per-user/${config.home.username}/bin/nvim";
        }
      );
    };
  };
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
    # WM tooling
    rofi
    flameshot
    dunst
    libnotify
    swaybg
    swayidle
    # file management
    yazi
    wl-clipboard
    # CLI
    neovim
    ripgrep
    fd
    # media
    playerctl
    # dev
    vscode
    nodejs
    pnpm
    tmux
    pkgs-unstable.bruno
    openssl
    # network
    protonvpn-gui
    # other
    beeper
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
        package =
          pkgs.runCommand "moveUp" {} ''
            mkdir -p $out/share/icons
            ln -s ${pkgs.fetchzip {
              url = url;
              hash = hash;
            }} $out/share/icons/${name}
          '';
      };
    in
      getFrom
        "https://github.com/dreamsofautonomy/banana-cursor/releases/download/v2.2.0/Banana.tar.xz"
        "sha256-FA7iKldiuvWizVcrbANGAKgtQ3r/7nQovn2Lk+utvIU="
        "Banana";
  home.sessionVariables = {
    XCURSOR_THEME = "Banana";
    XCURSOR_SIZE  = "36";
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
  historyControl = [ "ignoredups" "erasedups" ];
  shellAliases = {
    btw = "echo I use nixos, btw";
    # NixOS
    nrs       = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw";
    hms       = "home-manager switch --flake ~/nixos-dotfiles#nixos-btw";
    nix-clean = "sudo nix-collect-garbage -d";
    # Git
    gs  = "git status";
    ga  = "git add .";
    gc  = "git commit -m";
    gp  = "git push";
    gl  = "git pull";
    glo = "git log --oneline --graph --decorate";
    gco = "git checkout";
    gb  = "git branch";
    gd  = "git diff";
    # Navigation
    ".."  = "cd ..";
    "..." = "cd ../..";
    # Dev
    v    = "nvim";
    grep = "rg";
    cat  = "bat";
    ls   = "eza --icons";
    ll   = "eza -al --icons";
    la   = "eza -A --icons";
  };
};
  #################################
  # Git
  #################################
  programs.git = {
    enable = true;
    settings = {
      user.name  = "EdTosoy";
      user.email = "68400105+EdTosoy@users.noreply.github.com";
    };
  };
}