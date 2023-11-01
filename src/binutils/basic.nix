{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "binutils" "basic"

{
  environment.systemPackages = [ pkgs.binutils ];
}
