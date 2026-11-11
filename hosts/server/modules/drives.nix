{ pkgs, ... }:

{
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/b394dcfe-98d2-421f-b276-bb44d12ba403";
    fsType = "ext4";
    options = [ "rw" "users" ];
  };

  fileSystems."/mnt/hdd-smb" = {
    device = "/dev/disk/by-uuid/1a97377c-cad8-4ab8-808f-d5b044993866";
    fsType = "ext4";
    options = [ "rw" "nofail" "x-systemd.device-timeout=10s" ];
  };

  users.groups.smbguest = { };
  users.users.smbguest = {
    isSystemUser = true;
    group = "smbguest";
  };

  systemd.services.samba-share-setup = {
    description = "Set up ownership of the Samba disk";
    requires = [ "mnt-hdd\\x2dsmb.mount" ];
    after = [ "mnt-hdd\\x2dsmb.mount" ];
    bindsTo = [ "mnt-hdd\\x2dsmb.mount" ];
    before = [ "samba-smbd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.util-linux}/bin/mountpoint -q /mnt/hdd-smb
      ${pkgs.coreutils}/bin/chown smbguest:smbguest /mnt/hdd-smb
      ${pkgs.coreutils}/bin/chmod 0755 /mnt/hdd-smb
    '';
  };

  systemd.tmpfiles.rules = [
    "d /mnt/hdd 0755 hbarn users -"
  ];
}
