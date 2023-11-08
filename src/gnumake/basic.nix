{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gnumake" "basic"

{
  environment.systemPackages = [ pkgs.gnumake ];
}
