{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "zathura" "basic"

{
  home.programs.zathura = {
    enable = true;
  };
}
