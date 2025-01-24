{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.bash.shellAliases = {
    ssh = "kitty +kitten ssh";
  };
  environment.systemPackages = with pkgs; [
    # cli utils
    # git
    curl
    wget
    vim
    htop
    tmux
    gnome-keyring
    neofetch
    xdg-desktop-portal-wlr
    jq
    inetutils
    ntfs3g
    vendir
    python3
    openjdk
    mssql-tools
    postgresql
    mongodb

    # browser
    google_chrome # !!! fix
  ];
}