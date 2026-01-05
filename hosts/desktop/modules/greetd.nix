{ pkgs, mango, ... }:

let
  mangoSessions = "${mango.packages.${pkgs.stdenv.hostPlatform.system}.mango}/share/wayland-sessions";
  hyprlandSessions = "${pkgs.hyprland}/share/wayland-sessions";
  swaySessions = "${pkgs.sway-unwrapped}/share/wayland-sessions";
in {
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    extraEntries = ''
      menuentry "CachyOS" {
	search --label --set=root CachyOS
	linux /boot/vmlinuz-linux-cachyos root=LABEL=CachyOS rw quiet splash
	initrd /boot/initramfs-linux-cachyos.img
      }
    '';
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
	command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --sessions ${mangoSessions}:${hyprlandSessions}:${swaySessions}";
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
    mango
    sway
    hyprland
  '';

  security.pam.services.greetd = {};
}
