{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "nushell" "defaultSettings"
{
  home.programs.nushell = {
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
  };
  home.file.".functions.nu".source = ./functions.nu;
}
