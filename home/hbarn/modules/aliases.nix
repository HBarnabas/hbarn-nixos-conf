{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      ssk = "kitty +kitten ssh";
      nrs = "sudo nixos-rebuild switch --flake /home/hbarn/nix-conf";
    };
  };
}
