{ pkgs, ... }:

{
  wayland.windowManager.mango = {
    enable = true;

	settings = ''

		# bindings
		bind=super+shift,r,reload_config,
		bind=super,Return,spawn,kitty,
		bind=super+shift,q,killclient,
		bind=super,d,spawn,wofi --show drun,

		# move focus
		bind=super,h,focusdir,left,
		bind=super,j,focusdir,down,
		bind=super,k,focusdir,up,
		bind=super,l,focusdir,right,

		# move window
		bind=super,h,
		bind=super,j,
		bind=super,k,
		bind=super,l,

		# monitors
		monitorrule=DP-1,0.55,1,tile,0,1,0,0,3440,1440,144
		monitorrule=HDMI-A-2,0.55,1,vertical_tile,1,1,3440,0,1920,1080,60

	'';
  };
}
