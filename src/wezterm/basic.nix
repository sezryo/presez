{ config, lib, pkgs, inputs, ... }:

{
  home.programs.wezterm = {
    enable = true;
  };
  
  environment.systemPackages = [
    pkgs.wezterm
  ];
}
