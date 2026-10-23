{
  pkgs,
  ...
}: let
  stremioX11 = pkgs.writeShellScriptBin "stremio" ''
    export GDK_BACKEND=x11
    exec ${pkgs.stremio-linux-shell}/bin/stremio "$@"
  '';
in {
  home.packages = [
    stremioX11
  ];

  xdg.desktopEntries."com.stremio.Stremio" = {
    name = "Stremio";
    comment = "Freedom To Stream";
    exec = "${stremioX11}/bin/stremio %u";
    icon = "${pkgs.stremio-linux-shell}/share/icons/hicolor/scalable/apps/com.stremio.Stremio.svg";
    terminal = false;
    categories = [
      "Utility"
      "AudioVideo"
      "Video"
      "Player"
    ];
    mimeType = [
      "x-scheme-handler/stremio"
    ];
    settings = {
      Type = "Application";
      DBusActivatable = "false";
      StartupNotify = "true";
      Keywords = "Stremio;Media;Play;";
    };
  };
}