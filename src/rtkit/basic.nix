{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "rtkit" "basic"

{
  security.rtkit.enable = true; 
}
