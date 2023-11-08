{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "alacritty" "basic"

{
  home.programs.alacritty = {
    enable = true;
  };
}
