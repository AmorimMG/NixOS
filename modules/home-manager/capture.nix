{pkgs, ...}: let
  ocr = pkgs.tesseract.override {enableLanguages = ["eng" "deu"];};
  python = pkgs.python3.withPackages (ps: [ps.dbus-next]);
  portalCapture = pkgs.writeText "portal-capture.py" ''
    import asyncio
    import shutil
    import sys
    from pathlib import Path
    from urllib.parse import unquote, urlparse

    from dbus_next import Message, MessageType, Variant
    from dbus_next.aio import MessageBus


    async def main():
        bus = await MessageBus().connect()
        token = f"capture_{__import__('os').getpid()}"
        path = f"/org/freedesktop/portal/desktop/request/{bus.unique_name[1:].replace('.', '_')}/{token}"
        loop = asyncio.get_running_loop()
        response = loop.create_future()

        def on_message(message):
            if message.path == path and message.interface == "org.freedesktop.portal.Request" and message.member == "Response":
                if not response.done():
                    response.set_result(message.body)

        bus.add_message_handler(on_message)
        await bus.call(Message(
            destination="org.freedesktop.DBus",
            path="/org/freedesktop/DBus",
            interface="org.freedesktop.DBus",
            member="AddMatch",
            signature="s",
            body=[f"type='signal',interface='org.freedesktop.portal.Request',member='Response',path='{path}'"],
        ))
        options = {"handle_token": Variant("s", token), "interactive": Variant("b", True)}
        props = await bus.call(Message(
            destination="org.freedesktop.portal.Desktop",
            path="/org/freedesktop/portal/desktop",
            interface="org.freedesktop.DBus.Properties",
            member="Get",
            signature="ss",
            body=["org.freedesktop.portal.Screenshot", "version"],
        ))
        if props.message_type == MessageType.METHOD_RETURN and props.body[0].value >= 3:
            options["target"] = Variant("u", 4 if sys.argv[1] == "region" else 2)
        reply = await bus.call(Message(
            destination="org.freedesktop.portal.Desktop",
            path="/org/freedesktop/portal/desktop",
            interface="org.freedesktop.portal.Screenshot",
            member="Screenshot",
            signature="sa{sv}",
            body=["", options],
        ))
        if reply.message_type != MessageType.METHOD_RETURN:
            raise RuntimeError("Screenshot portal request failed")
        status, result = await asyncio.wait_for(response, timeout=120)
        if status:
            return 1
        uri = urlparse(result["uri"].value)
        if uri.scheme != "file":
            raise RuntimeError("Screenshot portal returned a non-file URI")
        shutil.copyfile(unquote(uri.path), Path(sys.argv[2]))
        return 0


    sys.exit(asyncio.run(main()))
  '';
  menu = pkgs.writeShellApplication {
    name = "desktop-menu";
    runtimeInputs = with pkgs; [coreutils fuzzel kdePackages.kdialog zenity];
    text = ''
      mapfile -t choices
      [ "''${#choices[@]}" -gt 0 ] || exit 1
      case "''${XDG_CURRENT_DESKTOP:-}" in
        *Hyprland*) printf '%s\n' "''${choices[@]}" | fuzzel --dmenu --prompt "''${1:-choose> }" --lines 9 ;;
        *KDE*) kdialog --combobox "''${1:-Choose}" "''${choices[@]}" ;;
        *) zenity --list --title="''${1:-Choose}" --column=Action --height=460 "''${choices[@]}" ;;
      esac
    '';
  };
  capture = pkgs.writeShellApplication {
    name = "desktop-capture";
    runtimeInputs = with pkgs; [
      coreutils
      gpu-screen-recorder
      grim
      hyprpicker
      kdePackages.spectacle
      libnotify
      satty
      slurp
      wl-clipboard
      zbar
      ocr
      menu
    ];
    text = ''
      action="''${1:-menu}"
      desktop="''${XDG_CURRENT_DESKTOP:-}"
      runtime="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      pid_file="$runtime/desktop-capture-recording.pid"

      recording_active() {
        [ -f "$pid_file" ] || return 1
        pid=$(< "$pid_file")
        [[ "$pid" =~ ^[0-9]+$ ]] || return 1
        [ -r "/proc/$pid/exe" ] || return 1
        [[ "$(readlink "/proc/$pid/exe")" == *gpu-screen-recorder* ]]
      }

      region_image() {
        case "$desktop" in
          *KDE*) spectacle --background --region --nonotify --output "$1" ;;
          *Hyprland*)
            geometry=$(slurp) || return 1
            grim -g "$geometry" "$1"
            ;;
          *) ${python}/bin/python ${portalCapture} region "$1" ;;
        esac
        [ -s "$1" ]
      }

      case "$action" in
        menu)
          choices=('Screenshot' 'Record screen' 'Extract text' 'Scan QR code' 'Transcode media')
          if [[ "$desktop" == *Hyprland* ]]; then choices+=('Pick color'); fi
          selection=$(printf '%s\n' "''${choices[@]}" | desktop-menu 'capture> ') || exit 0
          case "$selection" in
            'Screenshot') exec "$0" shot ;;
            'Record screen') exec "$0" record ;;
            'Extract text') exec "$0" ocr ;;
            'Scan QR code') exec "$0" qr ;;
            'Pick color') exec hyprpicker -a ;;
            'Transcode media') exec media-transcode ;;
          esac
          ;;
        shot)
          case "$desktop" in
            *KDE*) exec spectacle --region ;;
            *Hyprland*) exec caelestia screenshot --region ;;
          esac
          image=$(mktemp --suffix=.png)
          trap 'rm -f "$image"' EXIT
          region_image "$image" || exit 0
          satty --filename "$image"
          ;;
        ocr)
          image=$(mktemp --suffix=.png)
          trap 'rm -f "$image"' EXIT
          region_image "$image" || exit 0
          result=$(tesseract "$image" stdout -l deu+eng --psm 6 2>/dev/null) || true
          if [ -n "$result" ]; then
            printf '%s' "$result" | wl-copy
            notify-send -i edit-copy 'Text copied' "$(printf '%s' "$result" | head -c 160)"
          else
            notify-send -i dialog-warning 'No text found'
          fi
          ;;
        qr)
          image=$(mktemp --suffix=.png)
          trap 'rm -f "$image"' EXIT
          region_image "$image" || exit 0
          result=$(zbarimg --quiet --raw -Sdisable -Sqrcode.enable "$image" 2>/dev/null) || true
          if [ -n "$result" ]; then
            printf '%s' "$result" | wl-copy
            notify-send -i view-barcode-qr 'QR code copied' "$(printf '%s' "$result" | head -c 160)"
          else
            notify-send -i dialog-warning 'No QR code found'
          fi
          ;;
        record)
          case "$desktop" in
            *KDE*) exec spectacle --record region ;;
            *Hyprland*) exec caelestia record --region --sound ;;
          esac
          if recording_active; then
            kill -INT "$pid"
            rm -f "$pid_file"
            notify-send -i media-record 'Recording stopped' 'Saved in Videos'
            exit 0
          fi
          mkdir -p "$HOME/Videos"
          output="$HOME/Videos/screenrecording-$(date +%Y-%m-%d_%H-%M-%S).mp4"
          gpu-screen-recorder -w portal -f 30 -c mp4 -a 'default_output|default_input' -o "$output" &
          printf '%s\n' "$!" > "$pid_file"
          notify-send -i media-record 'Recording started' "$output"
          ;;
        *) printf 'Unknown capture action: %s\n' "$action" >&2; exit 2 ;;
      esac
    '';
  };
  transcode = pkgs.writeShellApplication {
    name = "media-transcode";
    runtimeInputs = with pkgs; [coreutils ffmpeg-full imagemagick kdePackages.kdialog libnotify menu];
    text = ''
      input="''${1:-}"
      if [ -z "$input" ]; then input=$(kdialog --getopenfilename "$HOME/Videos") || exit 0; fi
      if [ ! -f "$input" ]; then notify-send 'File not found' "$input"; exit 1; fi
      choice=$(printf '%s\n' 'MP4 · original size' 'MP4 · 1080p' 'WebM · 1080p' 'GIF · 720p' 'MP3 audio' 'FLAC audio' 'PNG image' 'JPEG image' 'WebP image' | desktop-menu 'convert> ') || exit 0
      base="''${input%.*}"
      case "$choice" in
        'MP4 · original size') output="$base-converted.mp4"; args=(-c:v libx264 -preset medium -crf 20 -c:a aac) ;;
        'MP4 · 1080p') output="$base-1080p.mp4"; args=(-vf 'scale=-2:1080:force_original_aspect_ratio=decrease' -c:v libx264 -preset medium -crf 21 -c:a aac) ;;
        'WebM · 1080p') output="$base-1080p.webm"; args=(-vf 'scale=-2:1080:force_original_aspect_ratio=decrease' -c:v libvpx-vp9 -crf 32 -b:v 0 -c:a libopus) ;;
        'GIF · 720p') output="$base-720p.gif"; args=(-vf 'fps=12,scale=-2:720:force_original_aspect_ratio=decrease') ;;
        'MP3 audio') output="$base-converted.mp3"; args=(-vn -c:a libmp3lame -q:a 2) ;;
        'FLAC audio') output="$base-converted.flac"; args=(-vn -c:a flac) ;;
        'PNG image') output="$base-converted.png"; args=(image) ;;
        'JPEG image') output="$base-converted.jpg"; args=(image) ;;
        'WebP image') output="$base-converted.webp"; args=(image) ;;
        *) exit 0 ;;
      esac
      if [ -e "$output" ]; then notify-send 'Output already exists' "$output"; exit 1; fi
      if { [ "''${args[0]}" = image ] && magick "$input" "$output"; } || { [ "''${args[0]}" != image ] && ffmpeg -hide_banner -nostdin -n -i "$input" "''${args[@]}" "$output"; }; then
        notify-send 'Media converted' "$output"
      else
        notify-send 'Conversion failed' "$input"
        exit 1
      fi
    '';
  };
in {
  home.packages = [capture transcode menu];

  systemd.user.sessionVariables.TESSDATA_PREFIX = "${ocr}/share/tessdata";

  xdg.desktopEntries.capture-menu = {
    name = "Capture";
    exec = "${capture}/bin/desktop-capture menu";
    icon = "camera-photo";
    categories = ["Utility"];
    noDisplay = true;
  };

  xdg.desktopEntries.capture-ocr = {
    name = "Extract Screen Text";
    exec = "${capture}/bin/desktop-capture ocr";
    icon = "edit-copy";
    categories = ["Utility"];
    noDisplay = true;
  };

  xdg.desktopEntries.capture-qr = {
    name = "Scan Screen QR Code";
    exec = "${capture}/bin/desktop-capture qr";
    icon = "view-barcode-qr";
    categories = ["Utility"];
    noDisplay = true;
  };
}
