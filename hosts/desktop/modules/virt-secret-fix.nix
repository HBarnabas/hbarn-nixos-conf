{ config, pkgs, ... }:

{
  # Fix for virt-secret-init-encryption.service using /usr/bin/sh
  # NixOS doesn't use FHS paths like /usr/bin, so we need to override this service

  # Option 1: Override the service to use proper NixOS paths (use if you need encrypted VM secrets)
  # systemd.services.virt-secret-init-encryption = {
  #   serviceConfig = {
  #     ExecStart = "${pkgs.bash}/bin/bash";
  #   };
  #   path = [ pkgs.bash pkgs.coreutils ];
  # };

  # Option 2: Disable the service entirely (uncomment if you don't use encrypted VM secrets)
  systemd.services.virt-secret-init-encryption.enable = false;
}
