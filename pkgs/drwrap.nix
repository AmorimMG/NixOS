# Source: https://github.com/fedsfarm/drwrap
{
  lib,
  python3Packages,
  fetchFromGitHub,
  ffmpeg-full,
  libnotify,
  procps,
  wl-clipboard,
  xclip,
}:
python3Packages.buildPythonApplication {
  pname = "drwrap";
  version = "0.1.0-unstable-2026-07-21";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fedsfarm";
    repo = "drwrap";
    rev = "2477d9d2eddfe2b96ce15b0221c91cbb5be3673c";
    hash = "sha256-b7ax62Pr9H/p1pD92ncb2uI+eBg7+PwG8rqZaP6+O/g=";
  };

  build-system = [python3Packages.setuptools];
  dependencies = [python3Packages.xlib];
  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ffmpeg-full libnotify procps wl-clipboard xclip]}"
  ];
  pythonImportsCheck = ["drwrap" "drwrap.clipboard" "drwrap.transcode"];

  meta = {
    description = "Media conversion and clipboard wrapper for DaVinci Resolve";
    homepage = "https://github.com/fedsfarm/drwrap";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "drwrap";
  };
}
