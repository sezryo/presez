{ pkgs, config, lib, ... }:

{
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    dpi = 160;
    libinput.touchpad = {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
      middleEmulation = true;
    };
  };
}
