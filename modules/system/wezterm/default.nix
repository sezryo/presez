{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [
    pkgs.wezterm
  ];
}
