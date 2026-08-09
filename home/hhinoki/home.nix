{ pkgs, ... }:

{
  home.username = "hhinoki";
  home.homeDirectory = "/home/hhinoki";
  programs.home-manager.enable = true;

  imports = [
    ./modules/apps.nix
    ./modules/plasma.nix
  ];

  home.stateVersion = "26.05"; # current release at creation time — do NOT copy hbarn's 24.05
}
