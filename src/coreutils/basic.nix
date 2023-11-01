{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "coreutils" "basic"

{
  environment.systemPackages = [ pkgs.coreutils ];
}
