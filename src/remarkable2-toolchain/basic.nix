{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "remarkable2-toolchain" "basic"

{
  home.packages = [ pkgs.remarkable2-toolchain ];
}
