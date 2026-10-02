{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  packages = lib.unique (config.home.packages ++ osConfig.environment.systemPackages);
  metadata =
    map (package: {
      name = lib.getName package;
      path = toString (lib.getBin package);
      description = package.meta.description or "";
      homepage = package.meta.homepage or "";
      mainProgram = package.meta.mainProgram or "";
    })
    packages;
in {
  xdg.configFile."software-library/packages.json".text = builtins.toJSON metadata;
  xdg.desktopEntries.software-library = {
    name = "Software Library";
    genericName = "Installed applications and terminal tools";
    comment = "Browse installed software by category, name and description";
    exec = lib.getExe pkgs.software-library;
    icon = "applications-all";
    categories = ["System" "Utility"];
    startupNotify = true;
    settings.StartupWMClass = "software-library";
  };
}
