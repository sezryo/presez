{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "htop" "basic"

{
  home.programs.htop = {
    enable = true;
  };
}
