{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gh" "basic"

  {
    home.programs.gh = {
      enable = true;
    };
  }
