{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gawk" "basic"

{
  environment.systemPackages = [ pkgs.gawk ];
}
