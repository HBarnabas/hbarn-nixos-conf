{ pkgs, ... }:

{
  programs.bash = {
    shellAliases = {
      ssh = "kitty +kitten ssh";
    };
  };

  programs.kitty = {
    enable = true;
		settings = {
		  confirm_os_window_close = 0;
		  font_family = "Roboto Mono";
		};
  };
}
