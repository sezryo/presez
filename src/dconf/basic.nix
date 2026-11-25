{ config, lib, pkgs, inputs, ... }:

{
  programs.dconf = {
    enable = true;
  };
}
