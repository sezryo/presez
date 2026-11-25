{ config, lib, pkgs, inputs, ... }:

{
  home.programs.nushell = {
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
  };
  home.file.".functions.nu".source = ./functions.nu;
}
