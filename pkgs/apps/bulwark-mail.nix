# Source: https://bulwarkmail.org
{
  lib,
  symlinkJoin,
  writeShellApplication,
  makeDesktopItem,
  google-chrome,
  zenity,
  coreutils,
}: let
  launcher = writeShellApplication {
    name = "bulwark-mail";
    runtimeInputs = [google-chrome zenity coreutils];
    text = ''
      umask 077
      config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/bulwark-mail"
      mkdir -p "$config_dir"
      url_file="$config_dir/url"
      url=""
      if [[ -f "$url_file" ]]; then
        IFS= read -r url < "$url_file" || true
      fi

      if [[ -z "$url" || "''${1:-}" == --configure ]]; then
        while true; do
          if ! url=$(zenity --entry --title="Bulwark Mail" \
            --text="Enter your Bulwark webmail URL" --entry-text="$url"); then
            exit 0
          fi
          if [[ "$url" =~ ^https?://[^/[:space:]?#]+([/?#][^[:space:]]*)?$ ]]; then
            break
          fi
          zenity --error --title="Bulwark Mail" \
            --text="Enter a complete http:// or https:// webmail address."
        done
        temporary=$(mktemp "$config_dir/url.XXXXXX")
        trap 'rm -f "$temporary"' EXIT
        printf '%s\n' "$url" > "$temporary"
        mv "$temporary" "$url_file"
        trap - EXIT
      fi

      exec google-chrome-stable --user-data-dir="$config_dir/browser" \
        --class=bulwark-mail --app="$url"
    '';
  };
  desktop = makeDesktopItem {
    name = "bulwark-mail";
    desktopName = "Bulwark Mail";
    genericName = "Webmail";
    comment = "Open your Bulwark webmail";
    exec = "bulwark-mail";
    icon = "internet-mail";
    categories = ["Network" "Email"];
    startupWMClass = "bulwark-mail";
    actions.configure = {
      name = "Change webmail URL";
      exec = "bulwark-mail --configure";
    };
  };
in
  symlinkJoin {
    name = "bulwark-mail-1.0.0";
    paths = [launcher desktop];
    meta = {
      description = "Bulwark webmail launcher with a locally configured URL";
      homepage = "https://bulwarkmail.org";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "bulwark-mail";
    };
  }
