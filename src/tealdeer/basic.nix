{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tealdeer" "basic"

{
  home.programs.tealdeer = {
    enable = true;
  };
}
