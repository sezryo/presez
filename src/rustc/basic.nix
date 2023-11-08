{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "rustc" "basic"

{
  home.packages = [ pkgs.rustc ];
}
