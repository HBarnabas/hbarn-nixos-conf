{ pkgs, config, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.mesa
    ];
    enable32Bit = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };
  # services.desktopManager.plasma6.enable = true;
}
