{ lib, pkgs, ... }:

{
  networking.hostName = "server";
  networking.useDHCP = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
     6443
     80
     443
  ];
  networking.firewall.allowedUDPPorts = [ 3478 ];

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -i enp6s0 -s 192.168.0.0/24 -p tcp --dport 445 -j nixos-fw-accept
  '';

  services.samba = {
    enable = true;
    openFirewall = false;
    nmbd.enable = false;
    winbindd.enable = false;
    settings = {
      global = {
        "interfaces" = "lo enp6s0";
        "bind interfaces only" = "yes";
        "smb ports" = 445;
        "hosts allow" = "127.0.0.1 192.168.0.0/24";
        "hosts deny" = "0.0.0.0/0 ::/0";
        "map to guest" = "Bad User";
        "guest account" = "smbguest";
      };
      hdd = {
        path = "/mnt/hdd-smb";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "guest only" = "yes";
        "force user" = "smbguest";
      };
    };
  };

  systemd.services.samba-smbd = {
    requires = [ "samba-share-setup.service" ];
    after = [ "samba-share-setup.service" ];
    bindsTo = [ "mnt-hdd\\x2dsmb.mount" ];
    unitConfig.RequiresMountsFor = lib.mkForce "/var/lib/samba /mnt/hdd-smb";
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  systemd.services.tailscale-udp-gro = {
    description = "Configure UDP GRO offloads for the Tailscale subnet router";
    wantedBy = [ "multi-user.target" "sys-subsystem-net-devices-enp6s0.device" ];
    bindsTo = [ "sys-subsystem-net-devices-enp6s0.device" ];
    after = [ "sys-subsystem-net-devices-enp6s0.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool -K enp6s0 rx-udp-gro-forwarding on rx-gro-list off";
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
