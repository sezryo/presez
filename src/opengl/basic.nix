{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "opengl" "basic"

{
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = lib.mkDefault true;
  };
}
