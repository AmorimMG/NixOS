let
  spaceIds = {
    pessoal = "c6de089c-410d-4206-961d-ab11f988d40a";
    estudos = "8a2c47f0-1d9e-4b36-a5c8-f70e92b4d615";
    trabalho = "cdd10fab-4fc5-494b-9041-325e5759195b";
  };

  containerIds = {
    pessoal = 1;
    estudos = 2;
    trabalho = 3;
  };
in {
  containers = {
    "Pessoal" = {
      id = containerIds.pessoal;
      color = "purple";
      icon = "fingerprint";
    };
    "Estudos" = {
      id = containerIds.estudos;
      color = "blue";
      icon = "chill";
    };
    "Trabalho" = {
      id = containerIds.trabalho;
      color = "orange";
      icon = "briefcase";
    };
  };

  spaces = {
    "Pessoal" = {
      id = spaceIds.pessoal;
      position = 1000;
      icon = "🏠";
      container = containerIds.pessoal;
    };
    "Estudos" = {
      id = spaceIds.estudos;
      position = 2000;
      icon = "📚";
      container = containerIds.estudos;
    };
    "Trabalho" = {
      id = spaceIds.trabalho;
      position = 3000;
      icon = "💼";
      container = containerIds.trabalho;
    };
  };

  pins = {
    "Hotmail (Pessoal)" = {
      id = "10000000-0000-4000-8000-000000000001";
      url = "https://outlook.live.com/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      isEssential = true;
      position = 1;
    };
    "YouTube (Pessoal)" = {
      id = "10000000-0000-4000-8000-000000000002";
      url = "https://youtube.com/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      isEssential = true;
      position = 2;
    };
    "Gemini (Pessoal)" = {
      id = "10000000-0000-4000-8000-000000000003";
      url = "https://gemini.google.com/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      isEssential = true;
      position = 3;
    };

    "Instagram" = {
      id = "10000000-0000-4000-8000-000000000103";
      url = "https://instagram.com/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      isEssential = true;
      position = 103;
    };
    "X" = {
      id = "10000000-0000-4000-8000-000000000104";
      url = "https://x.com";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      isEssential = true;
      position = 104;
    };
    "Homepage Local" = {
      id = "10000000-0000-4000-8000-000000000105";
      url = "http://localhost:8082/#home";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 105;
    };
    "Startpage" = {
      id = "10000000-0000-4000-8000-000000000106";
      url = "https://start.amorim.pro/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      isEssential = true;
      position = 106;
    };
    "Vaultwarden" = {
      id = "10000000-0000-4000-8000-000000000107";
      url = "https://vaultwarden.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 107;
    };
    "Seafile" = {
      id = "10000000-0000-4000-8000-000000000108";
      url = "https://seafile.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 108;
    };
    "Home Assistant" = {
      id = "10000000-0000-4000-8000-000000000109";
      url = "https://ha.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 109;
    };
    "Bambuddy" = {
      id = "10000000-0000-4000-8000-000000000110";
      url = "https://bambuddy.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 110;
    };
    "Jellyfin" = {
      id = "10000000-0000-4000-8000-000000000111";
      url = "https://jellyfin.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 111;
    };
    "Jellyseerr" = {
      id = "10000000-0000-4000-8000-000000000112";
      url = "https://jellyseerr.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 112;
    };
    "Navidrome" = {
      id = "10000000-0000-4000-8000-000000000113";
      url = "https://navidrome.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 113;
    };
    "Kavita" = {
      id = "10000000-0000-4000-8000-000000000114";
      url = "https://kavita.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 114;
    };
    "RomM" = {
      id = "10000000-0000-4000-8000-000000000115";
      url = "https://romm.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 115;
    };
    "AIOStreams" = {
      id = "10000000-0000-4000-8000-000000000116";
      url = "https://aiostreams.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 116;
    };
    "Radarr" = {
      id = "10000000-0000-4000-8000-000000000117";
      url = "https://radarr.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 117;
    };
    "Bazarr" = {
      id = "10000000-0000-4000-8000-000000000118";
      url = "https://bazarr.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 118;
    };
    "Prowlarr" = {
      id = "10000000-0000-4000-8000-000000000119";
      url = "https://prowlarr.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 119;
    };
    "qBittorrent" = {
      id = "10000000-0000-4000-8000-000000000120";
      url = "https://qbittorrent.uaru-piranha.ts.net/";
      workspace = spaceIds.pessoal;
      container = containerIds.pessoal;
      position = 120;
    };

    "Hotmail (Estudos)" = {
      id = "20000000-0000-4000-8000-000000000001";
      url = "https://outlook.live.com/";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      isEssential = true;
      position = 11;
    };
    "YouTube (Estudos)" = {
      id = "20000000-0000-4000-8000-000000000002";
      url = "https://youtube.com/";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      isEssential = true;
      position = 12;
    };
    "Gemini (Estudos)" = {
      id = "20000000-0000-4000-8000-000000000003";
      url = "https://gemini.google.com/";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      isEssential = true;
      position = 13;
    };
    "FIAP ON" = {
      id = "20000000-0000-4000-8000-000000000201";
      url = "https://on.fiap.com.br/";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      isEssential = true;
      position = 14;
    };

    "Learn Go with Tests" = {
      id = "20000000-0000-4000-8000-000000000202";
      url = "https://quii.gitbook.io/learn-go-with-tests";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      position = 202;
    };
    "Build Your Own X" = {
      id = "20000000-0000-4000-8000-000000000203";
      url = "https://github.com/codecrafters-io/build-your-own-x";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      position = 203;
    };
    "Claude" = {
      id = "20000000-0000-4000-8000-000000000204";
      url = "https://claude.ai/";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      position = 204;
    };
    "Google AI Studio" = {
      id = "20000000-0000-4000-8000-000000000206";
      url = "https://aistudio.google.com";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      position = 206;
    };
    "DeepSeek" = {
      id = "20000000-0000-4000-8000-000000000207";
      url = "https://chat.deepseek.com/";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      position = 207;
    };
    "Open WebUI" = {
      id = "20000000-0000-4000-8000-000000000208";
      url = "https://openwebui.uaru-piranha.ts.net";
      workspace = spaceIds.estudos;
      container = containerIds.estudos;
      position = 208;
    };

    "Hotmail (Trabalho)" = {
      id = "30000000-0000-4000-8000-000000000001";
      url = "https://outlook.live.com/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      isEssential = true;
      position = 21;
    };
    "YouTube (Trabalho)" = {
      id = "30000000-0000-4000-8000-000000000002";
      url = "https://youtube.com/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      isEssential = true;
      position = 22;
    };
    "Gemini (Trabalho)" = {
      id = "30000000-0000-4000-8000-000000000003";
      url = "https://gemini.google.com/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      isEssential = true;
      position = 23;
    };

    "NixOS Config" = {
      id = "30000000-0000-4000-8000-000000000301";
      url = "https://github.com/Muddyblack/NixOS";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 301;
    };
    "Git Amorim" = {
      id = "30000000-0000-4000-8000-000000000302";
      url = "https://git.amorim.pro/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 302;
    };
    "Kiro" = {
      id = "30000000-0000-4000-8000-000000000303";
      url = "https://app.kiro.dev/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 303;
    };
    "Woodpecker CI" = {
      id = "30000000-0000-4000-8000-000000000304";
      url = "https://woodpecker.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 304;
    };
    "Kubernetes" = {
      id = "30000000-0000-4000-8000-000000000305";
      url = "https://k8s.amorim.pro/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 305;
    };
    "ArgoCD (Prod)" = {
      id = "30000000-0000-4000-8000-000000000306";
      url = "https://argocd.amorim.pro/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 306;
    };
    "ArgoCD (Tailnet)" = {
      id = "30000000-0000-4000-8000-000000000307";
      url = "https://argocd.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 307;
    };
    "Longhorn" = {
      id = "30000000-0000-4000-8000-000000000308";
      url = "https://longhorn.amorim.pro/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 308;
    };
    "Oracle Cloud" = {
      id = "30000000-0000-4000-8000-000000000309";
      url = "https://idcs-b972f800c7a44c78b8dbd4758089b759.identity.oraclecloud.com/ui/v1/signin";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 309;
    };
    "Tailscale Console" = {
      id = "30000000-0000-4000-8000-000000000310";
      url = "https://console.tailscale.com/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 310;
    };
    "Pi-hole" = {
      id = "30000000-0000-4000-8000-000000000311";
      url = "https://pihole.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 311;
    };
    "Grafana" = {
      id = "30000000-0000-4000-8000-000000000312";
      url = "https://grafana.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 312;
    };
    "Prometheus" = {
      id = "30000000-0000-4000-8000-000000000313";
      url = "https://prometheus.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 313;
    };
    "MinIO" = {
      id = "30000000-0000-4000-8000-000000000314";
      url = "https://minio.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 314;
    };
    "MinIO (HTTP)" = {
      id = "30000000-0000-4000-8000-000000000315";
      url = "http://minio.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 315;
    };
    "ntfy" = {
      id = "30000000-0000-4000-8000-000000000316";
      url = "https://ntfy.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 316;
    };
    "Calagopus" = {
      id = "30000000-0000-4000-8000-000000000317";
      url = "https://calagopus.uaru-piranha.ts.net/";
      workspace = spaceIds.trabalho;
      container = containerIds.trabalho;
      position = 317;
    };
  };
}
