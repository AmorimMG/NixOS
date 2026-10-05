{pkgs, ...}: let
  # No tray icon: CopyQ is opened with Meta+Shift+V. disable_tray is a stored
  # CopyQ option, so set it once the server is up.
  start = pkgs.writeShellScript "copyq-start" ''
    ${pkgs.copyq}/bin/copyq --start-server hide &
    sleep 2
    ${pkgs.copyq}/bin/copyq config disable_tray true
    wait
  '';
in {
  home.packages = [pkgs.copyq];

  xdg.configFile."autostart/copyq.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=CopyQ
    Exec=${start}
    NotShowIn=GNOME;
    X-GNOME-Autostart-enabled=true
  '';

  xdg.desktopEntries.clipboard-history = {
    name = "Clipboard History";
    exec = "${pkgs.copyq}/bin/copyq toggle";
    icon = "copyq";
    categories = ["Utility"];
    noDisplay = true;
  };
}
