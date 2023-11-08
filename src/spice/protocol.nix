{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "spice" "protocol"

{
  environment.systemPackages = [ pkgs.spice-protocol ];
}
