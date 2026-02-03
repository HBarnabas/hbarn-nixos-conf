{ pkgs, config, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.mesa
    ];
  };

  services.xserver.videoDrivers = ["amdgpu"];
}
