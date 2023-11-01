{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ripgrep" "basic"

{
  home.packages = [ pkgs.ripgrep ];
}
