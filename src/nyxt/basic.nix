{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "nyxt" "basic"

{
  home.packages = [ pkgs.nyxt ];
}
