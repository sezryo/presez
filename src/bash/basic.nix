{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bash" "basic"

{
  home.packages = [ pkgs.bash ];
}
