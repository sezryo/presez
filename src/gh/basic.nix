{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gh" "basic"

  {
    home.programs.gh = {
      enable = true;
    };
  }
