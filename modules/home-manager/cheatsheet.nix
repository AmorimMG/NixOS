{pkgs, ...}: let
  hyprCheatsheet = pkgs.writeShellApplication {
    name = "hypr-cheatsheet";
    runtimeInputs = with pkgs; [coreutils fuzzel hyprland jq];
    text = ''
      hyprctl binds -j |
        jq -r '
          .[]
          | select(.submap == "" or .submap == "default")
          | select(.key != "")
          | [
              ([if ((.modmask / 64 | floor) % 2) == 1 then "Super" else empty end,
                if ((.modmask / 4 | floor) % 2) == 1 then "Ctrl" else empty end,
                if ((.modmask / 8 | floor) % 2) == 1 then "Alt" else empty end,
                if ((.modmask / 1 | floor) % 2) == 1 then "Shift" else empty end,
                .key] | join(" + ")),
              .dispatcher,
              .arg
            ]
          | join("  ·  ")
        ' | sort -u | fuzzel --dmenu --prompt 'shortcuts> ' --width 110 --lines 18 >/dev/null
    '';
  };
  desktopShortcuts = pkgs.writeShellApplication {
    name = "desktop-shortcuts";
    text = ''
      case "''${XDG_CURRENT_DESKTOP:-}" in
        *Hyprland*) exec ${hyprCheatsheet}/bin/hypr-cheatsheet ;;
        *KDE*) exec systemsettings kcm_keys ;;
        *GNOME*) exec gnome-control-center keyboard ;;
        *COSMIC*) exec cosmic-settings keyboard ;;
        *) printf 'No shortcut guide for this desktop\n' >&2; exit 1 ;;
      esac
    '';
  };
in {
  home.packages = [hyprCheatsheet desktopShortcuts];

  xdg.desktopEntries.desktop-shortcuts = {
    name = "Keyboard Shortcuts";
    exec = "${desktopShortcuts}/bin/desktop-shortcuts";
    icon = "input-keyboard";
    categories = ["Settings"];
    noDisplay = true;
  };
}
