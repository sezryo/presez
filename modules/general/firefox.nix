{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.firefox;
  inherit (lib.mine) mkEnableOpt mkOpt';
in {
  options.modules.general.firefox = {
    enable = mkEnableOpt "Enable basic firefox usages";
    enableDefault = mkEnableOpt "Whether to enable default firefox user and theme settings";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        firefox = [ "basic" ];
      };
    }
    (mkIf cfg.enableDefault {
      modules.singleton = {
        firefox = [ "defaultSettings" "simplefox" ];
      };
    })
  ]);
}
