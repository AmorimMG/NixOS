{
  pkgs,
  lib,
  config,
  ...
}: {
  options.features.gaming.enable = lib.mkEnableOption "gaming";

  config = lib.mkIf config.features.gaming.enable {
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    # Fixa o kernel para a versão LTS 6.18 para compatibilidade com o driver NVIDIA
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extraPackages = with pkgs; [
        mangohud
        protontricks
        steamtinkerlaunch
      ];
    };

    environment.systemPackages = with pkgs; [
      mangohud
      gperftools
    ];

    # ─────────────────────────────────────────────────────────────
    # Drivers NVIDIA (RTX 4060 / Ada Lovelace)
    # ─────────────────────────────────────────────────────────────
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      # Para Ada Lovelace, o módulo open também é oficialmente suportado.
      # Se quiser testar, troque para `true`. Ambos funcionam com a 4060.
      open = false;
    };

    # Evita corrupção de VRAM ao suspender/alternar janelas (bugs conhecidos na série 40)
    boot.kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];

    # ─────────────────────────────────────────────────────────────
    # Ajustes de rede (mantidos do original)
    # ─────────────────────────────────────────────────────────────
    boot.kernel.sysctl = {
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.ipv4.tcp_window_scaling" = 1;
      "net.ipv4.tcp_fastopen" = 3;
    };
  };
}