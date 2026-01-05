{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.mango.enable = true;
  environment.systemPackages = with pkgs; [
    gnome-keyring
    xdg-desktop-portal
    xdg-desktop-portal-wlr
  ];
}
