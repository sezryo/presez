{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wev" "basic"

{
  home.packages = [ pkgs.wev ];
}
