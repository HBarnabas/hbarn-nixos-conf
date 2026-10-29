{
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/b394dcfe-98d2-421f-b276-bb44d12ba403";
    fsType = "ext4";
    options = [ "rw" "users" ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/hdd 0755 hbarn users -"
  ];
}
