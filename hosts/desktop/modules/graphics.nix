{ pkgs, config, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.mesa
    ];
  };
}
