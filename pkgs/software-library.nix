# Source: https://github.com/Muddyblack/NixOS
{
  lib,
  stdenvNoCC,
  python3,
  kdePackages,
  glib,
  gobject-introspection,
  wrapGAppsNoGuiHook,
  makeWrapper,
}: let
  python = python3.withPackages (ps: [ps.pyqt6 ps.pygobject3]);
in
  stdenvNoCC.mkDerivation {
    pname = "software-library";
    version = "1.0.0";
    src = ./software-library;
    nativeBuildInputs = [makeWrapper kdePackages.wrapQtAppsHook wrapGAppsNoGuiHook gobject-introspection];
    buildInputs = [kdePackages.qtbase kdePackages.qtwayland kdePackages.qtsvg glib];
    dontWrapQtApps = true;
    dontWrapGApps = true;
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      QT_QPA_PLATFORM=offscreen ${python}/bin/python3 -B -m unittest discover -s tests -v
      runHook postCheck
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/software-library $out/bin
      cp catalog.py main.py $out/share/software-library/
      runHook postInstall
    '';
    preFixup = ''
      makeWrapper ${python}/bin/python3 $out/bin/software-library \
        --add-flags $out/share/software-library/main.py \
        "''${qtWrapperArgs[@]}" "''${gappsWrapperArgs[@]}"
    '';
    meta = {
      description = "Browse installed applications and terminal tools";
      mainProgram = "software-library";
      platforms = lib.platforms.linux;
    };
  }
