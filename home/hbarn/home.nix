{ pkgs, ... }:

{
  home.username = "hbarn";
  home.homeDirectory = "/home/hbarn";
  programs.home-manager.enable = true;

  imports = [
    ./modules/apps.nix
    ./modules/dev.nix
    ./modules/hyprland-wm.nix
    ./modules/mango.nix
    ./modules/sway-wm.nix
    ./modules/terminal.nix
    ./modules/waybar.nix
  ];

  home.keyboard = null;

  home.stateVersion = "24.05";
}
