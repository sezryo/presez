{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "lsd" "basic"

{
  home.programs.lsd = {
    enable = true;
  };
}
