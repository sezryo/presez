{ config, pkgs, inputs, ... }:

{
  boot.loader.grub.darkmatter-theme = {
    enable = true;
    style = "nixos";
    icon = "color";
    resolution = "1440p";
  };
}
