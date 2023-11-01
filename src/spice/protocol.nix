{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spice" "protocol"

{
  environment.systemPackages = [ pkgs.spice-protocol ];
}
