{
  pkgs,
  osConfig,
  ...
}: let
  # Fetched at build time so the daemon never downloads anything at runtime.
  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin";
    sha256 = "1zifp9gk9220vysx8a00mzf2sy05ni4l6crx95baivhlvp1mpvb0";
  };
in {
  home.packages = [pkgs.voxtype];

  xdg.desktopEntries.dictation-toggle = {
    name = "Toggle Dictation";
    exec = "${pkgs.voxtype}/bin/voxtype record toggle";
    icon = "audio-input-microphone";
    categories = ["Utility"];
    noDisplay = true;
  };

  systemd.user.services.voxtype = {
    Unit = {
      Description = "Voice dictation";
      After = ["graphical-session.target" "pipewire.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.voxtype}/bin/voxtype --no-hotkey --model ${whisperModel} --language auto --threads 4 --on-demand-loading --type-delay 2 --dotool-xkb-layout ${osConfig.keyboardLayout} daemon";
      Restart = "on-failure";
      RestartSec = "30s";
      RuntimeDirectory = "voxtype";

      # Transcription is fully local: the model is pinned in the store and the
      # service gets no network, so nothing can leave the machine.
      PrivateNetwork = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      # State file for `voxtype record toggle`, plus voxtype's own data/config.
      ReadWritePaths = ["%t/voxtype" "%h/.local/share/voxtype" "%h/.config/voxtype"];
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
