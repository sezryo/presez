{ config, pkgs, ... }:

{
  services = {
    printing.enable = true;
    avahi.enable = true;
    # for a WiFi printer
    avahi.openFirewall = true;
    # for an USB printer
    ipp-usb.enable = true;
    asusd.enable = true;
    supergfxd.enable = true;
  };

  hardware.pulseaudio.enable = false; # Being conflict to pipewire
  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
}
