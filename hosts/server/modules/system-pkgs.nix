{ pkgs, ... }:

{
  programs.git.enable = true;
  environment.systemPackages = with pkgs; [
    vim
    htop
    btop
    fluxcd
    kubectl
  ];
}
