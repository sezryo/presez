{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "flatpak" "basic"

{
  services.flatpak = {
    enable = true;
  };
}
