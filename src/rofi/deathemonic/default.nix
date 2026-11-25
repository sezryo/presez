{ config, lib, pkgs, inputs, ... }:

{
  home.configFile."rofi" = {
    source = ./myRofi;
    target = "rofi";
    recursive = true;
  };
}
