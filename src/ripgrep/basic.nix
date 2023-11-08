{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ripgrep" "basic"

{
  home.packages = [ pkgs.ripgrep ];
}
