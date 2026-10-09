# Source: https://github.com/Muddyblack/ai-usage-widget
{
  lib,
  stdenv,
  ai-usage-widget,
  aiUsageSrc,
  bash,
  cmake,
  coreutils,
  makeDesktopItem,
  ninja,
  python3,
  qt6,
  quickshell,
}: let
  quickshellDesktop = makeDesktopItem {
    name = "org.quickshell";
    desktopName = "Quickshell";
    comment = "QtQuick desktop shell runtime";
    exec = "${quickshell}/bin/qs";
    terminal = false;
    noDisplay = true;
    categories = ["Utility"];
  };
in
  stdenv.mkDerivation {
    pname = "ai-usage-hyprland";
    inherit (ai-usage-widget) version;
    src = aiUsageSrc;

    nativeBuildInputs = [cmake ninja qt6.wrapQtAppsHook];
    buildInputs = [qt6.qtbase qt6.qtwayland];
    cmakeDir = "../hosts/quickshell/tray";

    postInstall = ''
      mkdir -p "$out/share/ai-usage-widget"
      # shell.qml must sit at the repo root beside hosts/, ui/ and backend/: it is the Quickshell
      # entry point and its directory becomes the QML sandbox root, which has to
      # contain all of them for the shell's shared UI/JS imports to resolve.
      cp -r ../hosts ../ui ../backend ../shell.qml "$out/share/ai-usage-widget/"

      install -Dm644 ${quickshellDesktop}/share/applications/org.quickshell.desktop \
        "$out/share/applications/org.quickshell.desktop"

      cat > "$out/bin/ai-usage-hyprland" <<'EOF'
      #!${bash}/bin/bash
      set -eu
      export PATH=${lib.makeBinPath [bash coreutils python3]}:"$PATH"
      root=${placeholder "out"}/share/ai-usage-widget
      ${placeholder "out"}/bin/ai-usage-tray ${quickshell}/bin/qs \
        "$root/shell.qml" "$root/backend/sh/get-ai-usage" &
      tray_pid=$!
      trap 'kill "$tray_pid" 2>/dev/null || true' EXIT INT TERM
      ${quickshell}/bin/qs -p "$root/shell.qml"
      EOF
      chmod +x "$out/bin/ai-usage-hyprland"
    '';

    meta = {
      description = "Hyprland/Quickshell frontend of the AI usage widget";
      homepage = "https://github.com/Muddyblack/ai-usage-widget";
      mainProgram = "ai-usage-hyprland";
      platforms = ["x86_64-linux" "aarch64-linux"];
    };
  }
