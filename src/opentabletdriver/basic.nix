{ config, pkgs, lib, ... }:

{
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
}
