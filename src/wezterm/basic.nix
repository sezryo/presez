{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "wezterm" "basic"

{
  home.programs.wezterm = {
    enable = true;
  };
  
  environment.systemPackages = [
    pkgs.wezterm
  ];
}
