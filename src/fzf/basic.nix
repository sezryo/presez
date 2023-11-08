{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "fzf" "basic"

{
  home.programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
