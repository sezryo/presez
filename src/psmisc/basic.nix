{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "psmisc" "basic"

{
  home.packages = [ pkgs.psmisc ];
}
