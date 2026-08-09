{ pkgs, ... }:

let
  # Picks the session command based on the user that logged in.
  # greetd runs this as the authenticated user, so $USER is reliable here.
  session-dispatch = pkgs.writeShellScriptBin "session-dispatch" ''
    case "$USER" in
      hbarn) exec sway ;;
      hhinoki) exec startplasma-wayland ;;
      *) exec sway ;;
    esac
  '';
in
{
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    # extraEntries = ''
    #   # menuentry "CachyOS" {
    #   # search --label --set=root CachyOS
    #   # linux /boot/vmlinuz-linux-cachyos root=LABEL=CachyOS rw quiet splash
    #   # initrd /boot/initramfs-linux-cachyos.img
    #   # }

    #   menuentry "Win 11" {
    #   insmod part_gpt
    #   insmod fat
    #   search --no-floppy --file --set=root /EFI/Microsoft/Boot/bootmgfw.efi
    #   chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    #   }
    # '';
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd ${session-dispatch}/bin/session-dispatch";
        user = "greeter";
      };
      environment = {
        XDG_SESSION_TYPE = "wayland";
        XDG_RUNTIME_DIR = "/run/user/%UID%";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/%UID%/bus";
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
  '';

  security.pam.services.greetd = {};
}
