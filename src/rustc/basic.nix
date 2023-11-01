{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rustc" "basic"

{
  home.packages = [ pkgs.rustc ];
}
