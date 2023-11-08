{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "radeontop" "basic"

{
  home.packages = [ pkgs.radeontop ];
}
