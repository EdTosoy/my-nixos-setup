{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  #################################
  # Bootloader
  #################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #################################
  # Hostname / Networking
  #################################
  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  #################################
  # Timezone / Locale
  #################################
  time.timeZone = "Asia/Manila";
  i18n.defaultLocale = "en_US.UTF-8";

  #################################
  # Display / Qtile + Greetd
  # windowManager.qtile registers Qtile and manages Python deps.
  # greetd + tuigreet replaces LightDM as the display manager.
  # XWayland is kept for app compatibility.
  #################################
  services.xserver = {
    enable = true;  # keep for XWayland support
    videoDrivers = [ "modesetting" ];
    xkb.layout = "us";
    xkb.variant = "dvorak";
    windowManager.qtile = {
      enable = true;
      extraPackages = python3Packages: with python3Packages; [
        psutil
        dbus-python
      ];
    };
  };

  services.xserver.xkb.extraLayouts = {
    real-prog-dvorak = {
      description = "Real Programmers Dvorak";
      languages = [ "eng" ];
      symbolsFile = "${./real-prog-dvorak}";
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd 'qtile start -b wayland' --time --remember";
        user = "greeter";
      };
    };
  };

  #################################
  # Graphics
  #################################
  hardware.graphics.enable = true;

  #################################
  # Sound (PipeWire)
  #################################
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };

  # Fix bluetooth audio stuttering — increase PipeWire buffer
  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 48000;
      default.clock.quantum = 1024;
      default.clock.min-quantum = 1024;
      default.clock.max-quantum = 1024;
    };
  };

  #################################
  # Bluetooth
  #################################
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.settings = {
    Policy = {
      AutoEnable = true;
    };
  };

  #################################
  # User
  #################################
  users.users.johncarlojose = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
    ];
    # password is set via secrets.nix module in flake.nix
  };

  #################################
  # Fonts
  #################################
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "Hack Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
    };
  };

  #################################
  # System Packages
  #################################
  environment.systemPackages = with pkgs; [
    # system utilities
    tree
    wget
    curl
    unzip
    # networking
    networkmanagerapplet
    wireguard-tools
    # bluetooth
    bluez
    bluez-tools
    # audio
    pavucontrol
    # greeter
    tuigreet
  ];

  #################################
  # Firefox
  #################################
  programs.firefox.enable = true;

  #################################
  # Allow unfree
  #################################
  nixpkgs.config.allowUnfree = true;

  programs.dconf.enable = true;

  #################################
  # Nix settings
  #################################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.firewall.checkReversePath = false;

  #################################
  # Docker
  #################################
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  #################################
  # State Version
  #################################
  system.stateVersion = "25.11";
}