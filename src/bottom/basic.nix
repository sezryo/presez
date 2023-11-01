{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bottom" "basic"

  {
    home.programs.bottom = {
      enable = true;
    };
  }
