{ pkgs, ...}:

{
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.kernelModules = [
    "wireguard"
    "ip_tables"
    "iptable_filter"
    "iptable_nat"
    "xt_MASQUERADE"
    "xt_conntrack"
  ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.src_valid_mark" = 1;
  };
}
