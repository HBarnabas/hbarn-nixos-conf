# Sway config imported into configuration.nix

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
    mako
  ];

  # use sway from home-manager in flake.nix
#  programs.sway.enable = true;

  security.polkit.enable = true;
}
