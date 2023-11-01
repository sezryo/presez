{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "firefox" "basic"

{
  
  environment.systemPackages = [ pkgs.firefox ];
  
  home.programs.firefox = {
    enable = true;
  };
}
