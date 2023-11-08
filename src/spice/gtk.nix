{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "spice" "gtk"

{
  environment.systemPackages = [ pkgs.spice-gtk ];
}
