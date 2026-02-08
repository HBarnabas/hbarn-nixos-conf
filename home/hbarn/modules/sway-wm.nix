{ pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;

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
      # startup = [
      #   {
      #     always = true;
      #     command = "exec quickshell";
      #   }
      # ];
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
    '';
  };
}
