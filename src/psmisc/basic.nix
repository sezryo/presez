{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "psmisc" "basic"

{
  home.packages = [ pkgs.psmisc ];
}
