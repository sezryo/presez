{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "flatpak" "basic"

{
  services.flatpak = {
    enable = true;
  };
}
