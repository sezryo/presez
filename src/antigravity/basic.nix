{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [
    pkgs.antigravity-cli
    pkgs.antigravity-acp
  ];
}
