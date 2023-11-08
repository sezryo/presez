{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "bottom" "basic"

  {
    home.programs.bottom = {
      enable = true;
    };
  }
