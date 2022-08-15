{ pkgs, lib, ... }:

{
  services.picom = {
    enable = true;
    backend = "glx";

    activeOpacity = "1.0";
    inactiveOpacity = "0.85";
    opacityRule = [ "100:class_i != 'st-256color'" ];

    fade = true;
    fadeDelta = 5;

    shadow = true;
    shadowOpacity = "0.75";

    vSync = true;

    blur = true;
  };
}
