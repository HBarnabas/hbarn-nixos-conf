{ ... }:

let
  sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGP7AchxWEbl9Y9MHv6QNu8PV12s33ECA/2HGGFBNIdA hbarn@nixos";
in
{
  imports = [
    ./hardware-configuration.nix
    ../desktop/modules/enable-flake.nix
  ];

  assertions = [
    {
      assertion = sshPublicKey != "";
      message = "Set sshPublicKey in hosts/server/configuration.nix before deploying the server.";
    }
  ];

  networking.hostName = "server";
  networking.useDHCP = true;
  networking.firewall.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };

  users.users.hbarn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ sshPublicKey ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [ "--kubelet-arg=fail-swap-on=false" ];
  };

  system.stateVersion = "26.05";
}
