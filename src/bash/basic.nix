{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "bash" "basic"

{
  home.packages = [ pkgs.bash ];
}
