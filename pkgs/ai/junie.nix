# Source: https://github.com/JetBrains/junie
{
  lib,
  stdenv,
  callPackage,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  fontconfig,
  freetype,
  zlib,
}: let
  source = callPackage ./source.nix {} "junie";
in
  stdenv.mkDerivation {
    pname = "junie";
    inherit (source) version src;

    sourceRoot = ".";

    dontBuild = true;
    dontConfigure = true;

    nativeBuildInputs = [unzip autoPatchelfHook makeWrapper];
    buildInputs = [alsa-lib fontconfig freetype stdenv.cc.cc.lib zlib];

    autoPatchelfIgnoreMissingDeps = [
      "libX11.so.6"
      "libXext.so.6"
      "libXi.so.6"
      "libXrender.so.1"
      "libXtst.so.6"
      "libwayland-client.so.0"
      "libwayland-cursor.so.0"
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec
      cp -a . $out/libexec/junie
      makeWrapper $out/libexec/junie/junie-app/bin/junie $out/bin/junie \
        --add-flags "--skip-update-check"
      runHook postInstall
    '';

    meta = {
      description = "JetBrains' official Junie coding agent CLI";
      homepage = "https://junie.jetbrains.com/";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = "junie";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
