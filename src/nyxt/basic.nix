{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nyxt" "basic"

{
  home.packages = [ pkgs.nyxt ];
}
