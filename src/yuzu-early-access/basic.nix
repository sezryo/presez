{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yuzu-early-access" "basic"

{
  home.packages = [ pkgs.yuzu-early-access ];
}
