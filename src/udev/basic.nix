{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "udev" "basic"

{
  services.udev = {
    enable = true;
  };
}
