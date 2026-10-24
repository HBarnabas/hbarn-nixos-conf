{ config, pkgs, ...}:

{
  # nixpkgs.config.pulseaudio = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    audio.enable = true;
    jack.enable = false;
    extraConfig = {
      pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 2048;
        };
      };
      pipewire-pulse."92-low-latency" = {
        "pulse.properties" = {
          "pulse.min.req" = "512/48000";
          "pulse.default.req" = "512/48000";
          "pulse.max.req" = "512/48000";
          "pulse.min.quantum" = "128/48000";
          "pulse.max.quantum" = "2048/48000";
        };
        "stream.properties" = {
          "node.latency" = "512/48000";
          "resample.quality" = 1;
        };
      };
    };
  };
  environment.systemPackages = with pkgs; [
    easyeffects
    dconf
    wireplumber
    playerctl
    pavucontrol  # GUI volume control (PulseAudio compatibility)
    # Note: Use 'wpctl' (from wireplumber) for CLI instead of pulseaudio-ctl
    # wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+   # volume up
    # wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-   # volume down
    # wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle  # mute toggle
  ];
}
