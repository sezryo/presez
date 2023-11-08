{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dconf" "basic"

{
  programs.dconf = {
    enable = true;
  };
}
