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
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
	  ./greetd.nix
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
		sublime-merge
		btop
		mc
	      ];
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
		userName = "HBarnabas";
		userEmail = "hbarnabas@outlook.com";
	      };
	      wayland.windowManager.sway = {
		enable = true;
		config = rec {
		  modifier = "Mod4"; # Super
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
		      workspace = "6";
		    }
		    {
		      output = "HDMI-A-2";
		      workspace = "7";
		    }
		    {
		      output = "HDMI-A-2";
		      workspace = "8";
		    }
		  ];
		};
	        extraConfig = ''
		  bindsym Print			exec shotman -c output
		  bindsym Print+Shift		exec shotman -c region
		  bindsym Print+Shift+Control 	exec shotman -c window
		'';
	      };
	      home.stateVersion = "24.05";
	    };
          }
        ];
      };
    };
  };
}
