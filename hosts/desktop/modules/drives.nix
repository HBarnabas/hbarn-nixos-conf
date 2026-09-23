{
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/home/hbarn/mnt/ssd-sam-sata" = {
    device = "/dev/disk/by-uuid/f776225b-184a-435c-af7e-b989204f1e9c";
    fsType = "ext4";
    options = [ "rw" "users" ];
  };
  # HDD physically removed from the machine — keep the definition for later
  # re-installation, but don't try to mount it at boot.
  # fileSystems."/home/hbarn/mnt/hdd-sea-sata" = {
  #   device = "/dev/disk/by-uuid/b394dcfe-98d2-421f-b276-bb44d12ba403";
  #   fsType = "ext4";
  #   # `exec` must come after `users`: the `users` option implies
  #   # `noexec,nosuid,nodev`, which breaks Nix builds run from the HDD-backed
  #   # build-dir (configure scripts become non-executable => exit code 126).
  #   options = [ "rw" "users" "exec" ];
  # };
  # fileSystems."/home/hbarn/mnt/ssd-wd-sata-0" = {
  #   device = "/dev/disk/by-uuid/745df3ae-9a14-4195-b63d-f9da0e387a2c";
  #   fsType = "ext4";
  #   # `exec` must come after `users`: the `users` option implies
  #   # `noexec,nosuid,nodev`, which would break Nix builds run from the
  #   # SSD-backed build-dir (configure scripts become non-executable => exit 126).
  #   options = [ "rw" "users" "exec" ];
  # };
  fileSystems."/home/hbarn/mnt/ssd-wd-sata-1" = {
    device = "/dev/disk/by-uuid/91d6f4aa-6969-48d3-9c92-1b2e2fe92626";
    fsType = "ext4";
    options = [ "rw" "users" "exec"];
  };
  fileSystems."/home/hbarn/mnt/ssd-sam-m2" = {
    device = "/dev/disk/by-uuid/e520eea0-f6fc-49e8-a5b5-fe1ba39de675";
    fsType = "ext4";
    options = [ "rw" "users" ];
  };
  systemd.tmpfiles.rules = [
    "d /home/hbarn/mnt/ssd-sam-sata 0755 hbarn users -"
    # "d /home/hbarn/mnt/hdd-sea-sata 0755 hbarn users -"
    "d /home/hbarn/mnt/ssd-wd-sata-0 0755 hbarn users -"
    "d /home/hbarn/mnt/ssd-wd-sata-1 0755 hbarn users -"
    "d /home/hbarn/mnt/ssd-sam-m2 0755 hbarn users -"
  ];
}
