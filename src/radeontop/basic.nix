{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "radeontop" "basic"

{
  home.packages = [ pkgs.radeontop ];
}
