{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gcc" "basic"

{
  home.packages = [ pkgs.gcc ];
}
