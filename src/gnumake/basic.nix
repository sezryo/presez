{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnumake" "basic"

{
  environment.systemPackages = [ pkgs.gnumake ];
}
