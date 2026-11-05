{
  pkgs,
  lib,
  inputs,
  ...
}: let
  ublockFilterLists = [
    "ublock-filters"
    "ublock-badware"
    "ublock-privacy"
    "ublock-quick-fixes"
    "ublock-unbreak"
    "easylist"
    "easyprivacy"
    "urlhaus-1"
    "plowe-0"
    "adguard-spyware-url"
    "block-lan"
    "fanboy-cookiemonster"
    "ublock-cookies-easylist"
    "fanboy-ai-suggestions"
    "easylist-chat"
    "easylist-newsletters"
    "easylist-notifications"
    "easylist-annoyances"
    "adguard-mobile-app-banners"
    "adguard-other-annoyances"
    "adguard-popup-overlays"
    "adguard-widgets"
    "ublock-annoyances"
    "TUR-0"
  ];

  extConfig = import ./extensions.nix {filterLists = ublockFilterLists;};
  spacesConfig = import ./spaces.nix;
in {
  imports = [inputs.zen-browser.homeModules.beta];

  home.activation.migrateLegacyZenProfile = lib.hm.dag.entryBetween ["zen-browser-default"] ["linkGeneration"] ''
    if [ ! -f "$HOME/.config/zen/default/zen-sessions.jsonlz4" ]; then
      for old_sessions in \
        "$HOME/.zen/wy7yxo70.Default Profile/zen-sessions.jsonlz4" \
        "/persist/home/$USER/.zen/wy7yxo70.Default Profile/zen-sessions.jsonlz4"; do
        if [ -f "$old_sessions" ]; then
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/zen/default"
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp "$old_sessions" "$HOME/.config/zen/default/zen-sessions.jsonlz4"
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod 644 "$HOME/.config/zen/default/zen-sessions.jsonlz4"
          break
        fi
      done
    fi
  '';

  programs.zen-browser = {
    enable = true;
    policies = {
      ExtensionSettings = extConfig.policies;
    };
    profiles.default = {
      isDefault = true;
      id = 0;
      bookmarks = import ./bookmarks.nix;
      settings = import ./settings.nix;
      userChrome = builtins.readFile ./userChrome.css;
      userContent = builtins.readFile ./userContent.css;
      containersForce = true;
      inherit (spacesConfig) containers;
      spacesForce = true;
      inherit (spacesConfig) spaces;
      pinsForce = true;
      pinsForceAction = "remove";
      inherit (spacesConfig) pins;
      search = {
        engines = import ./search-engines.nix {inherit pkgs;};
        force = true;
        default = "ddg";
        privateDefault = "ddg";
      };
      extensions = {
        force = true;
        settings = extConfig.settings;
      };
    };
  };
}
