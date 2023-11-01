{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "starship" "basic"

{
  home.programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
