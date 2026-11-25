{ config, lib, pkgs, inputs, ... }:

{
  home.programs.swaylock = {
    enable = true;
  };
  security.pam.services.swaylock.text = "auth include login";
}
