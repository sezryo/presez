{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "fuzzel" "basic"

{
  home.packages = [ pkgs.fuzzel ];
}
