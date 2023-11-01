{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "libreoffice" "basic"

  {
    home.packages = [ pkgs.libreoffice ];
  }
