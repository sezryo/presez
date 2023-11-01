{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dconf" "basic"

{
  programs.dconf = {
    enable = true;
  };
}
