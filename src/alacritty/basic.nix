{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "alacritty" "basic"

{
  home.programs.alacritty = {
    enable = true;
  };
}
