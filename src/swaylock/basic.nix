{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "swaylock" "basic"

{
  home.programs.swaylock = {
    enable = true;
  };
  security.pam.services.swaylock.text = "auth include login";
}
