{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "fuzzel" "basic"

{
  home.packages = [ pkgs.fuzzel ];
}
