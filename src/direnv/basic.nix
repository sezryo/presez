{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "direnv" "basic"

{
  home.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };
}
