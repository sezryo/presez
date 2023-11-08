{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "pipewire" "basic"

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  hardware.pulseaudio.enable = false; # Being conflict to pipewire
}
