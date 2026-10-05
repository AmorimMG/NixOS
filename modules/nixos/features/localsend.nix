{
  lib,
  config,
  ...
}: {
  options.features.localsend.enable = lib.mkEnableOption "LocalSend device sharing";

  config = lib.mkIf config.features.localsend.enable {
    networking.firewall.allowedTCPPorts = [53317];
    networking.firewall.allowedUDPPorts = [53317];
  };
}
