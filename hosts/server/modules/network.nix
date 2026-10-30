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
