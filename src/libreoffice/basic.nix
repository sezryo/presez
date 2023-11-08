{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "libreoffice" "basic"

  {
    home.packages = [ pkgs.libreoffice ];
  }
