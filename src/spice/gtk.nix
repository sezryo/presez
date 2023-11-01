{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spice" "gtk"

{
  environment.systemPackages = [ pkgs.spice-gtk ];
}
