{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.desktop.skwd-wall;
  qdbusCompat = pkgs.runCommand "skwd-qdbus-compat" {} ''
  mkdir -p "$out/bin"

  ln -s "${pkgs.kdePackages.qttools}/bin/qdbus" \
    "$out/bin/qdbus6"

  ln -s "${pkgs.kdePackages.qttools}/bin/qdbus" \
    "$out/bin/qdbus-qt6"
  '';

  skwdWalld =
    if osConfig.features.desktops.plasma.enable then
      pkgs.writeShellScriptBin "skwd-walld" ''
        export PATH="${qdbusCompat}/bin:${pkgs.kdePackages.qttools}/bin:$PATH"

        exec "${pkgs.skwd-wall}/bin/skwd-walld" "$@"
      ''
    else
      pkgs.skwd-wall;
in {
  options.desktop.skwd-wall = {
    enable =
      lib.mkEnableOption "Skwd-wall wallpaper engine"
      // {default = osConfig.features.desktops.wallpaperEngine == "skwd";};
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [pkgs.skwd-wall]
      ++ lib.optional osConfig.features.desktops.plasma.enable pkgs.skwd-wall-plasma;

    # Skwd is session-aware (--wait-for-session) and drives KWin through
    # skwd-wall-plasma as well as Hyprland, so it follows the generic session
    # target instead of Hyprland's. COSMIC and GNOME keep their own wallpaper.
    systemd.user.services.skwd-walld = {
      Unit = {
        Description = "Skwd Deck wallpaper service";
        Conflicts = ["skwd-daemon.service"];
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${skwdWalld}/bin/skwd-walld --wait-for-session";
        Restart = "on-failure";
        RestartSec = 2;
        Slice = "session.slice";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    wayland.windowManager.hyprland.settings.bind = lib.mkIf osConfig.features.desktops.hyprland.enable [
      "$mod, W, exec, ${pkgs.skwd-wall}/bin/skwd-wall-v2"
      "$mod SHIFT, W, exec, ${pkgs.skwd-wall}/bin/skwd-helm next"
      "$mod ALT, W, exec, ${pkgs.skwd-wall}/bin/skwd-helm pause"
      "$mod ALT SHIFT, W, exec, ${pkgs.skwd-wall}/bin/skwd-helm resume"
    ];
  };
}
