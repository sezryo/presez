{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wlogout" "basic"

{
  home.programs.wlogout = {
    enable = true;
  };
}
