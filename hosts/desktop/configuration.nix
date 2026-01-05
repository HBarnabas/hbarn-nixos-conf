# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/audio-config.nix
    ./modules/drives.nix
    ./modules/env-vars.nix
    ./modules/fonts.nix
    ./modules/greetd.nix
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/system-packages.nix
    ./modules/users.nix
    ./modules/vm.nix
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
