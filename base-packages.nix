{ config, pkgs, ... }:

let 
  unstable = import <unstable> { config = {allowUnfree = true; }; };
in

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.bash = {
    shellAliases = {
      ssh = "kitty +kitten ssh";
    };
  };
  environment.systemPackages = with pkgs; [
    # cli utils
    # git
    sway
    hyprland
    curl
    wget
    vim
    htop
    tmux
    gnome-keyring
    tenv # set TENV_AUTO_INSTALL=true
    tflint
    (unstable.google-cloud-sdk.withExtraComponents( with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      kubectl
      docker-credential-gcr
    ]))
    #  gdk
    neofetch
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    terraform-docs
    go-task
    jq
    inetutils
    ntfs3g
    vendir
    unzip
    python311
    vlc
    gnome-sudoku
    unstable.heroic
    slack
    unstable.code-cursor
    unstable.zed-editor-fhs    
    unstable.dotnetCorePackages.dotnet_8.sdk
    unstable.dotnetCorePackages.dotnet_9.sdk
    jdk8
    gimp3
    memtester
    stress
    deluge
    unrar
#    teamspeak3

    # browser
    microsoft-edge # !!! fix
  ];
}
