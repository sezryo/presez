{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rofi" "deathemonic"
{
  home.configFile."rofi" = {
    source = ./myRofi;
    target = "rofi";
    recursive = true;
  };
}
