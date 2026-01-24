{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-keyring
    wlroots_0_19
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    swayfx

    # Provided by the overlay in `flake.nix`
    ps4-pkg-tools
  ];

  hardware.opentabletdriver.enable = true;
}
