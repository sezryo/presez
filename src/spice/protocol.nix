{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [ pkgs.spice-protocol ];
}
