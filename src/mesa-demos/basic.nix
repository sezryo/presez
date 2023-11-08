{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "mesa-demos" "basic"

{
  home.packages = [ pkgs.mesa-demos ];
}
