{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "binutils" "basic"

{
  environment.systemPackages = [ pkgs.binutils ];
}
