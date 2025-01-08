{ config, pkgs, ... }:

let
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
    kubectl
    docker-credential-gcr
  ]);
in

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
    tenv # set TENV_AUTO_INSTALL=true
    gdk
    neofetch
    xdg-desktop-portal-wlr
    terraform-docs
    go-task
    jq
    inetutils
    ntfs3g
    vendir

    # browser
    microsoft-edge # !!! fix
  ];
}
