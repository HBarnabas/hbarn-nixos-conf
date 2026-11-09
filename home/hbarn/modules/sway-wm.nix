{ pkgs, ... }:

let
  # json-c 0.19 leaks nested objects in release builds. Limit the backport to
  # SwayFX so other packages can continue using the binary cache.
  swayPackage =
    if pkgs.json_c.version == "0.19" then
      let
        jsonCFix = pkgs.fetchurl {
          url = "https://github.com/json-c/json-c/commit/f291fa81c6f21d925ea771a8cca597f5886309cc.patch";
          hash = "sha256-QoNmM/zn+kdVrnJF+zArwEDYJL5fnOqo7UUQzk+i5Gs=";
        };
        jsonCFixed = pkgs.json_c.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            if grep -Fq 'assert(_json_object_put_maybe_free(jso, 1) == 0);' json_object.c; then
              patch -p1 < ${jsonCFix}
            elif ! grep -Fq 'rc = _json_object_put_maybe_free(jso, 1);' json_object.c; then
              echo "json-c 0.19 memory leak fix could not be verified" >&2
              exit 1
            fi
          '';
        });
      in
      pkgs.swayfx.override {
        swayfx-unwrapped = pkgs.swayfx-unwrapped.override {
          json_c = jsonCFixed;
        };
      }
    else
      pkgs.swayfx;
in
{
  wayland.windowManager.sway = {
    enable = true;
    package = swayPackage;

    checkConfig = false;

    config = {
      modifier = "Mod4"; # Super
      input = {
        "*" = {
          xkb_layout = "us,hu";
          xkb_options = "grp:win_space_toggle";
        };
      };
      terminal = "kitty";
      output = {
        "DP-1" = {
          mode = "3440x1440@144Hz";
          position = "0,0";
        };
        "HDMI-A-2" = {
          mode = "1920x1080@60Hz";
          position = "3440,0";
          transform = "270";
        };
      };
      workspaceOutputAssign = [
        { output = "DP-1"; workspace = "1"; }
        { output = "DP-1"; workspace = "2"; }
        { output = "DP-1"; workspace = "3"; }
        { output = "DP-1"; workspace = "4"; }
        { output = "DP-1"; workspace = "5"; }
        { output = "HDMI-A-2"; workspace = "6"; }
        { output = "HDMI-A-2"; workspace = "7"; }
        { output = "HDMI-A-2"; workspace = "8"; }
        { output = "HDMI-A-2"; workspace = "9"; }
      ];
      startup = [
        # Start the PCPanel controller in the background (no window).
        # Running `pcpanel` manually later will show the window of the
        # already-running instance.
        { command = "pcpanel quiet"; }
      ];
      bars = [
        { mode = "invisible"; }
      ];
    };
    extraConfigEarly = ''
      gaps inner 6
      gaps outer 4
      default_border pixel 2
      corner_radius 8
      blur enable
      blur_radius 8
      blur_passes 2
      shadows enable
      shadow_color 000000AA
      shadow_blur_radius 20
      exec quickshell
    '';
    extraConfig = ''
      bindsym Print			exec shotman -c output
      bindsym Print+Shift		exec shotman -c region
      bindsym Print+Shift+Control 	exec shotman -c window

      # Media controls
      bindsym Mod4+F1 exec playerctl play-pause
      bindsym Mod4+F2 exec playerctl previous
      bindsym Mod4+F3 exec playerctl next

      # Audio controls
      bindsym Mod4+F4 exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindsym Mod4+F5 exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindsym Mod4+F6 exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    '';
  };
}
