{ pkgs, ... }:

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
