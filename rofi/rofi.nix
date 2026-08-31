{
  # Hide unwanted Rofi entries
  xdg.dataFile = {
    "applications/xterm.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=XTerm
      Hidden=true
    '';

    "applications/foot.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Foot
      Hidden=true
    '';

    "applications/rofi.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Rofi
      Hidden=true
    '';

    "applications/rofi-theme-selector.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Rofi Theme Selector
      Hidden=true
    '';

    "applications/footclient.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Foot Client
      Hidden=true
    '';

    "applications/foot-server.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Foot Server
      Hidden=true
    '';

    "applications/nixos-manual.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=NixOS Manual
      Hidden=true
    '';

    "applications/nvim.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Neovim
      Hidden=true
    '';

    "applications/blueman-manager.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Bluetooth Manager
      Hidden=true
    '';

    "applications/nm-connection-editor.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Advanced Network Configuration
      Hidden=true
    '';
  };
}
