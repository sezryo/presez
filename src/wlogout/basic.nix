{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "wlogout" "basic"

{
  home.programs.wlogout = {
    enable = true;
  };
}
