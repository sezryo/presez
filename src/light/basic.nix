{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "light" "basic"

{
  programs.light = {
    enable = true;
  };
}
