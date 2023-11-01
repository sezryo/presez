{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "htop" "basic"

{
  home.programs.htop = {
    enable = true;
  };
}
