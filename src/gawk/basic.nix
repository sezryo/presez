{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gawk" "basic"

{
  environment.systemPackages = [ pkgs.gawk ];
}
