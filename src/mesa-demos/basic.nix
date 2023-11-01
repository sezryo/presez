{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "mesa-demos" "basic"

{
  home.packages = [ pkgs.mesa-demos ];
}
