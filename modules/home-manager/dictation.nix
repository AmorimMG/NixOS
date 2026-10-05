{
  pkgs,
  osConfig,
  ...
}: {
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
      ExecStartPre = "${pkgs.voxtype}/bin/voxtype setup --download --model base --quiet --no-post-install";
      ExecStart = "${pkgs.voxtype}/bin/voxtype --no-hotkey --model base --language auto --threads 4 --on-demand-loading --type-delay 2 --dotool-xkb-layout ${osConfig.keyboardLayout} daemon";
      Restart = "on-failure";
      RestartSec = "30s";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
