{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wezterm" "basic"

{
  home.programs.wezterm = {
    enable = true;
  };
  
  environment.systemPackages = [
    pkgs.wezterm
  ];
}
