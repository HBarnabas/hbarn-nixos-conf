{ pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # BASIC SETTINGS (Sway-like)
      animations = {
        enabled = false;
      };
      decoration = {
        rounding = 0;
        #		    blur = false;
        #		    drop_shadow = false;
      };

      "$mod" = "SUPER";

      # KEYBINDINGS
      bind = [
        "$mod, Return, exec, kitty"
        "$mod SHIFT, Q, killactive"
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod SHIFT, 1, movetoworkspacesilent, 1"
        "$mod SHIFT, 2, movetoworkspacesilent, 2"
        "$mod SHIFT, 3, movetoworkspacesilent, 3"
        "$mod SHIFT, 4, movetoworkspacesilent, 4"
        "$mod SHIFT, 5, movetoworkspacesilent, 5"
        "$mod SHIFT, 6, movetoworkspacesilent, 6"
        "$mod SHIFT, 7, movetoworkspacesilent, 7"
        "$mod SHIFT, 8, movetoworkspacesilent, 8"
        "$mod SHIFT, 9, movetoworkspacesilent, 9"
        "$mod SHIFT, 0, movetoworkspacesilent, 10"
        "$mod, D, exec, fuzzel"
        "$mod, F, fullscreen, 1, toggle"
        "$mod, V, layoutmsg, preselect d"
        "$mod, B, layoutmsg, preselect r"
        # Screenshots
        ", Print, exec, grim - | wl-copy"
        "SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT CTRL, Print, exec, grim -g \"$(hyprctl activewindow -j | jq -r '.at.x, .at.y, .size.w, .size.h | \"\\\"\\(.[0]),\\(.[1]) \\(.[2])x\\(.[3])\\\"\"')\" - | wl-copy"
      ];

      # MOUSE MOVE AND RESIZE
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # INPUT
      input = {
        kb_layout = "us,hu";
        kb_options = "grp:win_space_toggle";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      # WINDOW MANAGEMENT
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
      };

      # LAYOUT SETTINGS
      dwindle = {
        force_split = 2;
        preserve_split = true;
      };

      # MONITORS
      monitor = [
        "DP-1, 3440x1440@144, 0x0, 1"
        "HDMI-A-2, 1920x1080@60, 3440x0, 1, transform, 1"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      workspace = [
        "1, monitor:DP-1"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-1"
        "5, monitor:DP-1"

        "6, monitor:HDMI-A-2"
        "7, monitor:HDMI-A-2"
        "8, monitor:HDMI-A-2"
        "9, monitor:HDMI-A-2"
      ];

      # STARTUP
      exec-once = [
        "layoutmsg preselect r"
        #		    "hyprpaper"
      ];
    };
  };
  # services.hyperpaper = {
		# enable = true;
		# settings = {
		#   preload = [ "/path/to/wallpaper" ];
		#   wallpaper = [
		#     "DP-1,/path/to/wallpaper"
		#     "DP-2,/path/to/wallpaper"
		#     "HDMI-A-2,/path/to/wallpaper"
		#   ];
		# };
  # };
}
