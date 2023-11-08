{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "yuzu-early-access" "basic"

{
  home.packages = [ pkgs.yuzu-early-access ];
}
