{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "coreutils" "basic"

{
  environment.systemPackages = [ pkgs.coreutils ];
}
