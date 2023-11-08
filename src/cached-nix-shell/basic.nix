{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "cached-nix-shell" "basic"

{
  environment.systemPackages = [ pkgs.cached-nix-shell ];
}
