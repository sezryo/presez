{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [ pkgs.cached-nix-shell ];
}
