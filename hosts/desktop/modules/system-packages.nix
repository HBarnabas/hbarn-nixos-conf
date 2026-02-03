{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-keyring
    wlroots_0_19
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    swayfx
    mangohud

    # Provided by the overlay in `flake.nix`
    ps4-pkg-tools
  ];

  hardware.opentabletdriver.enable = true;
}
