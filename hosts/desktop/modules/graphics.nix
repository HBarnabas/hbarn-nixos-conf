{ pkgs, config, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.mesa
    ];
  };

  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };
  services.desktopManager.plasma6.enable = true;
}
