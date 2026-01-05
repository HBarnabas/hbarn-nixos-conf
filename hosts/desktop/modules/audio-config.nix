{ config, pkgs, ...}:

{
  nixpkgs.config.pulseaudio = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    audio.enable = true;
    jack.enable = false;
  };
  environment.systemPackages = [
    pkgs.easyeffects
    pkgs.dconf
    pkgs.wireplumber
  ];
}
