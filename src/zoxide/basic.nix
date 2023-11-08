{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "zoxide" "basic"

{
  home.programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    package = pkgs.zoxide; 
  };
}
