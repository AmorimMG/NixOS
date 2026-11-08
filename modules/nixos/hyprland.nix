{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
lib.mkIf config.features.desktops.hyprland.enable {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config.hyprland = {
      default = ["hyprland" "kde" "gtk"];
      "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
      "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
      "org.freedesktop.impl.portal.GlobalShortcuts" = ["hyprland"];
      "org.freedesktop.impl.portal.Settings" = ["kde" "gtk"];
    };
  };

  security.pam.services.hyprlock = {};

  environment.systemPackages = with pkgs; [
    hyprpicker
    hyprshot
    satty
    hyprlock
    hypridle
    wl-clipboard
    grim
    slurp
    brightnessctl
    playerctl
    pavucontrol
    libnotify
    networkmanagerapplet
    # Hyprland's own polkit agent, replacing polkit_gnome: Qt/Wayland-native,
    # so authentication dialogs match the rest of the session instead of
    # rendering as an unthemed GTK window. Started from exec-once in
    # modules/home-manager/hyprland.nix.
    hyprpolkitagent
    inputs.snappy-switcher.packages.${pkgs.system}.default
  ];

  services.gnome.gnome-keyring.enable = true;
}
