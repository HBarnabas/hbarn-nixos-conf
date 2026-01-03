{
#  fileSystems."/home/hbarn/mnt/ssd-sam-sata" = {
#    device = "/dev/disk/by-uuid/68ce718b-41ca-4f8c-b6b8-a830303d3887";
#    fsType = "ext4";
#    options = [ "nofail" ];
#  };
  fileSystems."/home/hbarn/mnt/hdd-sea-sata" = {
    device = "/dev/disk/by-uuid/F8B86E53B86E1104";
    fsType = "ntfs";
    options = [ "nofail" ];
  };
  fileSystems."/home/hbarn/mnt/ssd-wd-sata-0" = {
    device = "/dev/disk/by-uuid/745df3ae-9a14-4195-b63d-f9da0e387a2c";
    fsType = "ext4";
    options = [ "nofail" ];
  };
  fileSystems."/home/hbarn/mnt/ssd-wd-sata-1" = {
    device = "/dev/disk/by-uuid/91d6f4aa-6969-48d3-9c92-1b2e2fe92626";
    fsType = "ext4";
    options = [ "nofail" ];
  };
  fileSystems."/home/hbarn/mnt/ssd-sam-m2" = {
    device = "/dev/disk/by-uuid/e520eea0-f6fc-49e8-a5b5-fe1ba39de675";
    fsType = "ext4";
    options = [ "nofail" ];
  };
  systemd.tmpfiles.rules = [
    "d /home/hbarn/mnt/ssd-sam-sata 0755 hbarn users -"
    "d /home/hbarn/mnt/hdd-sea-sata 0755 hbarn users -"
    "d /home/hbarn/mnt/ssd-wd-sata-0 0755 hbarn users -"
    "d /home/hbarn/mnt/ssd-wd-sata-1 0755 hbarn users -"
    "d /home/hbarn/mnt/ssd-sam-m2 0755 hbarn users -"
  ];
}
