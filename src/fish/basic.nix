{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "fish" "basic"

{
  home.programs.fish = {
    enable = true;
  };
}
