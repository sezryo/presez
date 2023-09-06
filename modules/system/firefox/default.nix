{ pkgs, config, lib, ... }:

{
  environment.systemPackages = [
    pkgs.firefox
  ];
}
