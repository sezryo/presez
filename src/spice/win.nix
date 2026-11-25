{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [ pkgs.win-spice ];
}
