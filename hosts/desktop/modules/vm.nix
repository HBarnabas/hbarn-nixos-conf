{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  # enable dconf
  programs.dconf.enable = true;

  # add user to libvirtd group
  users.users.hbarn.extraGroups = [ "libvirtd" ];

  # install packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
  ];

  # virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        #	ovmf.enable = true;
        #	ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
