{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "light" "basic"

{
  programs.light = {
    enable = true;
  };
}
