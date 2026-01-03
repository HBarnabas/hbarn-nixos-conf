{ pkgs, tuigreet-latest, config, ... }:

let
  hyprlandSessions = "${pkgs.hyprland}/share/wayland-sessions";
  swaySessions = "${pkgs.sway-unwrapped}/share/wayland-sessions";
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
	command = "${tuigreet-latest}/bin/tuigreet --time --asterisks --user-menu --sessions ${hyprlandSessions}:${swaySessions}";
	user = "greeter";
      };
      environment = {
	XDG_SESSION_TYPE = "wayland";
	XDG_RUNTIME_DIR = "/run/user/%UID%";
	DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/%UID/bus";
	PATH = "/run/current-system/sw/bin";
      };
    };
  };

  users.users.greeter = {
    isSystemUser = true;
    description = "Greetd user";
    createHome = true;
    home = "/var/lib/greetd";
    shell = pkgs.bashInteractive;
  };

  environment.etc."greetd/environments".text = ''
    sway
    hyprland
  '';

  security.pam.services.greetd = {};
}
