{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "awscli2" "basic"

{
  home.packages = [ pkgs.awscli2 ];
}
