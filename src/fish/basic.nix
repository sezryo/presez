{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "fish" "basic"

{
  home.programs.fish = {
    enable = true;
  };
}
