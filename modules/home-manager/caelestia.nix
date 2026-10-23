{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: {
  programs.caelestia = {
    enable = true;
    # Both from nixpkgs-unstable via the overlay: the module's own defaults
    # build the upstream flake, which recompiles quickshell from git.
    package = pkgs.callPackage ../../pkgs/caelestia-shell.nix {};
    systemd.enable = true;
    cli.enable = true;
    cli.package = pkgs.caelestia-cli;
    settings = {
      bar.status = {
        showAudio = true;
        showMicrophone = true;
        showBattery = true;
        showNetwork = true;
        showBluetooth = true;
      };
      appearance = {
        deformScale = 1.0;

        rounding = {
          scale = 1.15;
        };

        spacing = {
          scale = 1.05;
        };

        padding = {
          scale = 1.03;
        };

        anim.durations.scale = 1.05;

        transparency = {
          enabled = true;
          base = 0.87;
          layers = 0.4;
        };
      };
      background = {
        enabled = true;
        # The selected wallpaper engine owns the background layer (skwd-wall.nix).
        wallpaperEnabled =
          !(config.desktop.skwd-wall.enable);
        desktopClock = {
          # modern-clock-hyprland (hyprland.nix) replaces it when enabled.
          enabled = !config.desktop.widgets.modernClock.enable;
          position = "middle-center";
        };
        visualiser = {
          enabled = true;
          autoHide = true;
          blur = true;
          rounding = 1;
          spacing = 1;
        };
      };
      dashboard = {
        enabled = true;
        showDashboard = true;
        showMedia = true;
        showWeather = true;
        showPerformance = true;

        performance = {
          showCpu = true;
          showGpu = true;
          showMemory = true;
          showStorage = true;
          showNetwork = true;
          showBattery = true;
        };
      };
      utilities = {
        enabled = true;
        cards.keepAwake = true;
      };
      paths = {
        wallpaperDir = "${../../assets/wallpapers}";
      };
      services = {
        useFahrenheit = false;
        weatherLocation = "";
      };
      session = {
        commands = {
          logout = ["hyprctl" "dispatch" "exit"];
          # The menu's hibernate-labeled button. Which command it actually
          # runs is controlled by features.hibernate.sessionButtonAction
          # (modules/nixos/features/hibernate.nix) — "sleep" by default.
          # Switching it to "hibernate" only works once features.hibernate
          # is enabled and its resumeOffset pinned; until then logind
          # refuses the call rather than silently suspending instead.
          hibernate =
            if osConfig.features.hibernate.sessionButtonAction == "hibernate"
            then ["systemctl" "hibernate"]
            else ["systemctl" "suspend"];
        };
      };
    };
  };

  systemd.user.services.caelestia = {
    Unit = {
      After = lib.mkForce ["hyprland-session.target"];
      PartOf = lib.mkForce ["hyprland-session.target"];
    };
    Service.Environment = [
      "NIXPKGS_QT6_QML_IMPORT_PATH=${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
    Install.WantedBy = lib.mkForce ["hyprland-session.target"];
  };

  home.activation.caelestiaWritableConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    cfg="$HOME/.config/caelestia/shell.json"
    if [ -L "$cfg" ]; then
      $DRY_RUN_CMD cp --remove-destination "$(readlink "$cfg")" "$cfg"
      $DRY_RUN_CMD chmod 644 "$cfg"
    fi
  '';

  # Bound to Ctrl+Shift+Esc in both sessions: Plasma gets its own system
  # monitor, Hyprland falls back to btop in a terminal.
  xdg.dataFile."applications/caelestia-monitor.desktop".text = ''
    [Desktop Entry]
    Name=System Monitor
    Exec=caelestia-monitor
    Type=Application
    NoDisplay=true
  '';

  home.packages = with pkgs; [
    (writeShellScriptBin "caelestia-monitor" ''
      if [[ "''${XDG_CURRENT_DESKTOP:-}" == *"KDE"* ]] && command -v plasma-systemmonitor &>/dev/null; then
          exec plasma-systemmonitor
      else
          exec ghostty -e btop
      fi
    '')

    material-symbols
    nerd-fonts.caskaydia-cove
    libqalculate
    aubio
    lm_sensors
    ddcutil
    app2unit
    # caelestia hardcodes `swappy -f <file|->`; satty takes the same flag
    (writeShellScriptBin "swappy" ''
      exec ${satty}/bin/satty "$@"
    '')
  ];
}
