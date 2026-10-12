# Source: https://github.com/storytold
{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  gcc-unwrapped,
  wayland,
  libxkbcommon,
  vulkan-loader,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
  fontconfig,
  alsa-lib,
  pname,
  version,
  hash,
}: let
  libs = [
    wayland
    libxkbcommon
    vulkan-loader
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
    fontconfig
    alsa-lib
  ];
in
  stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/storytold/${pname}/releases/download/v${version}/${pname}-${version}-linux-x86_64.tar.gz";
      inherit hash;
    };

    nativeBuildInputs = [autoPatchelfHook makeWrapper];
    buildInputs = [gcc-unwrapped.lib] ++ libs;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r bin share $out/
      for f in $out/bin/*; do
        wrapProgram $f --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs}:/run/opengl-driver/lib
      done
      runHook postInstall
    '';

    meta = {
      homepage = "https://getartcraft.com/apps/${pname}";
      license = lib.licenses.asl20;
      platforms = ["x86_64-linux"];
      mainProgram = pname;
    };
  }
