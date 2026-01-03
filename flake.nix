{
  description = "flake for nixos";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuigreet-src = {
      url = "github:apognu/tuigreet";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, tuigreet-src }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    tuigreet-latest = pkgs.rustPlatform.buildRustPackage {
      pname = "tuigreet";
      version = "git";
      src = tuigreet-src;

      cargoLock.lockFile = tuigreet-src + "/Cargo.lock";

      doCheck = false;

      meta = {
        description = "Graphical console greeter for greetd";
        license = pkgs.lib.licenses.gpl3Plus;
      };
    };
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
	    home-manager.useGlobalPkgs = true;
	    home-manager.useUserPackages = true;
	    home-manager.users.hbarn = { pkgs, ... }: {
	      home.username = "hbarn";
	      home.homeDirectory = "/home/hbarn";
	      programs.home-manager.enable = true;
              home.packages = with pkgs; [
		keepassxc
		mako
		wl-clipboard
		shotman
		spotify
		vscode
		pavucontrol
		discord
		webcord
		discord-canary
		sublime-merge
		btop
		mc
	      ];
	      home.keyboard = null;
	      programs.kitty = {
	        enable = true;
		settings = {
		  confirm_os_window_close = 0;
		  font_family = "Roboto Mono";
		};
	      };
	      programs.vscode = {
		package = pkgs.vscode.fhs;
	      };
	      programs.git = {
		enable = true;
		settings.user = {
		  name = "HBarnabas";
		  email = "hbarnabas@outlook.com";
		};
	      };
	      programs.fuzzel = {
		enable = true;
	      };
	      wayland.windowManager.sway = {
		enable = true;
		config = rec {
		  modifier = "Mod4"; # Super
		  input = {
		    "*" = {
		      xkb_layout = "us,hu";
		      xkb_options = "grp:win_space_toggle";
		    };
		  };
		  terminal = "kitty";
		  output = {
		    "DP-2" = {
		      mode = "1280x1024@60Hz";
		      position = "0,0";
		    };
		    "DP-1" = {
		      mode = "3440x1440@144Hz";
		      position = "1280,0";
		    };
		    "HDMI-A-2" = {
		      mode = "1920x1080@60Hz";
		      position = "4720,0";
		      transform = "270";
		    };
		  };
		  workspaceOutputAssign = [
		    {
		      output = "DP-1";
		      workspace = "1";
		    }
		    {
		      output = "DP-1";
		      workspace = "2";
		    }
		    {
		      output = "DP-1";
		      workspace = "3";
		    }
		    {
		      output = "HDMI-A-2";
		      workspace = "4";
		    }
		    {
		      output = "HDMI-A-2";
		      workspace = "5";
		    }
		    {
		      output = "HDMI-A-2";
		      workspace = "6";
		    }
		    {
		      output = "DP-2";
		      workspace = "7";
		    }
		    {
		      output = "DP-2";
		      workspace = "8";
		    }
		    {
		      output = "DP-2";
		      workspace = "9";
		    }
		  ];
		};
	        extraConfig = ''
		  bindsym Print			exec shotman -c output
		  bindsym Print+Shift		exec shotman -c region
		  bindsym Print+Shift+Control 	exec shotman -c window
		'';
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
#		    "kitty"
#		    "waybar"
#		    "hyprpaper"
		  ];
		};
	      };
#	      services.hyperpaper = {
#		enable = true;
#		settings = {
#		  preload = [ "/path/to/wallpaper" ];
#		  wallpaper = [
#		    "DP-1,/path/to/wallpaper"
#		    "DP-2,/path/to/wallpaper"
#		    "HDMI-A-2,/path/to/wallpaper"
#		  ];
#		};
#	      };
	      home.stateVersion = "24.05";
	    };
          }

	  ./greetd.nix
	  {
	    _module.args.tuigreet-latest = tuigreet-latest;
	  }
        ];
      };
    };
  };
}
