{ pkgs, lib, ... }:

# Declarative equivalent of the "new virtual network" step in
# https://linuxconfig.org/how-to-use-bridged-networking-with-libvirt-and-kvm
#
# Instead of `virsh net-define`/`net-start`/`net-autostart` by hand, define
# the libvirt network XML here and (idempotently) register it with libvirtd
# on activation. VMs can then select the "br0-bridge" network to get an IP
# straight from the LAN's DHCP server via the `br0` bridge configured in
# ./networking.nix, instead of being NATed behind the default virbr0 network.

let
  networkName = "br0-bridge";
  networkXml = pkgs.writeText "${networkName}.xml" ''
    <network>
      <name>${networkName}</name>
      <forward mode='bridge'/>
      <bridge name='br0'/>
    </network>
  '';
in
{
  systemd.services.libvirt-br0-network = {
    description = "Define and start the libvirt ${networkName} bridged network";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.libvirt ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      if ! virsh net-info ${networkName} >/dev/null 2>&1; then
        virsh net-define ${networkXml}
      fi
      virsh net-start ${networkName} 2>/dev/null || true
      virsh net-autostart ${networkName}
    '';
  };
}
