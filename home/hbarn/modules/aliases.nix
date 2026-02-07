{ pkgs, ... }:

{
  home.shellAliases = {
    ssh = "kitty +kitten ssh";
    nrs = "sudo nixos-rebuild switch --flake /home/hbarn/nix-conf";
  };
}
