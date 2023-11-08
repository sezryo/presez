{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "lsd" "basic"

{
  home.programs.lsd = {
    enable = true;
  };
}
