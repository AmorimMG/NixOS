{pkgs, ...}: {
  xdg.configFile."drwrap/config.toml".source = (pkgs.formats.toml {}).generate "drwrap-config.toml" {
    edition.studio = false;
    launcher.resolve_bin = "${pkgs.davinci-resolve}/bin/davinci-resolve";
    poolwatch.enabled = false;
    transcode.workers = 1;
    watch = {
      folder = "~/Videos/ResolveDrop";
      ready_folder = "~/Videos/ResolveIngest";
    };
  };

  xdg.desktopEntries.drwrap = {
    name = "DaVinci Resolve (media conversion)";
    genericName = "Video Editor";
    exec = "${pkgs.drwrap}/bin/drwrap";
    icon = "davinci-resolve";
    terminal = false;
    categories = ["AudioVideo" "AudioVideoEditing" "Video"];
    settings.StartupWMClass = "resolve";
  };
}
