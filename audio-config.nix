{ config, pkgs, ...}:

{
  nixpkgs.config.pulseaudio = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
#    jack.enable = true;
  };
  environment.systemPackages = [
    pkgs.easyeffects
    pkgs.dconf
  ];
}
