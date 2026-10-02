{ config, pkgs, ... }:
{
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

  #################################
  # Defualt System Theme to Darkmode
  #################################
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
    };
  };

  #################################
  # GTK / Qt
  #################################
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    gtk4.theme = config.gtk.theme;
    cursorTheme = {
      name = "Banana";
      size = 36;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

}
