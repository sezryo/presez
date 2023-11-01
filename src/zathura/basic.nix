{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zathura" "basic"

{
  home.programs.zathura = {
    enable = true;
  };
}
