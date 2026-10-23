{lib, ...}: {
  options.features.desktops = {
    hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Hyprland session";
    };
    plasma.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "KDE Plasma 6 session";
    };
    cosmic.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "COSMIC session";
    };
    gnome.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "GNOME session";
    };
    wallpaperEngine = lib.mkOption {
      type = lib.types.enum [
        "skwd"
        "none"
      ];
      default = "skwd";
      description = ''
         Optional wallpaper engine for supported desktop sessions.
         "skwd" enables the Skwd-wall integration.
         "none" disables Skwd-wall and leaves wallpaper management
         to the desktop environment's native implementation.
      '';
    };
  };
}
