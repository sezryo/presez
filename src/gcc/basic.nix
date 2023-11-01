{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gcc" "basic"

{
  home.packages = [ pkgs.gcc ];
}
