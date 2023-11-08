{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "tealdeer" "basic"

{
  home.programs.tealdeer = {
    enable = true;
  };
}
