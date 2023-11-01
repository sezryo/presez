{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rtkit" "basic"

{
  security.rtkit.enable = true; 
}
