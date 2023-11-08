{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "wev" "basic"

{
  home.packages = [ pkgs.wev ];
}
