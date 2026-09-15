{ config, ... }:

{
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # --- Bridged networking for libvirt/KVM VMs (declarative equivalent of
  # https://linuxconfig.org/how-to-use-bridged-networking-with-libvirt-and-kvm) ---
  #
  # `br0` replaces `enp16s0` on the host: the physical NIC is enslaved to the
  # bridge and no longer gets an IP itself, `br0` does (via DHCP here). VMs
  # attached to `br0` then appear as regular hosts on the LAN instead of being
  # NATed behind virbr0.
  networking.bridges.br0.interfaces = [ "enp16s0" ];
  networking.interfaces.br0.useDHCP = true;
  networking.interfaces.enp16s0.useDHCP = false;

  # Both interfaces are now managed declaratively above; keep NetworkManager
  # (still used for e.g. wlp15s0) from touching them, mirroring the manual
  # `nmcli`/keyfile steps the tutorial has you do by hand.
  networking.networkmanager.unmanaged = [ "interface-name:enp16s0" "interface-name:br0" ];
}
