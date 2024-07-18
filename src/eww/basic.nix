{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "eww" "basic"

{
  home.programs.eww = {
    enable = true;
  };
}
