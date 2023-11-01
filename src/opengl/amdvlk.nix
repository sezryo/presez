{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "opengl" "amdvlk"

{
  hardware.opengl = {
    extraPackages = with pkgs; [
      amdvlk
    ];
    
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
}
