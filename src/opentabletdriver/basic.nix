{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "opentabletdriver" "basic"

{
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
}
