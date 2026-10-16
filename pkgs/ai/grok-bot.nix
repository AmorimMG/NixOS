# Source: https://x.ai/bot
{
  lib,
  fetchurl,
  appimageTools,
}: let
  version = "0.70.2";
  commit = "52da656f56d317510ca65ad6af3d69a2cde461e0";
  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/${commit}/linux/x64/Grok_Bot_${version}.AppImage";
    hash = "sha256-Y/7sjAuZdsslKJsTpchZjNuIK6nvLSks6ZDMQntGouA=";
  };
  extracted = appimageTools.extract {
    pname = "grok-bot";
    inherit version src;
  };
in
  appimageTools.wrapType2 {
    pname = "grok-bot";
    inherit version src;

    extraInstallCommands = ''
      install -Dm644 ${extracted}/grok-bot.desktop $out/share/applications/grok-bot.desktop
      substituteInPlace $out/share/applications/grok-bot.desktop --replace-fail "Exec=AppRun" "Exec=grok-bot"
      cp -r ${extracted}/usr/share/icons $out/share/icons
    '';

    meta = {
      description = "xAI Grok Bot desktop app";
      homepage = "https://x.ai/bot";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = "grok-bot";
    };
  }
