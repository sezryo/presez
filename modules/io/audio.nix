{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.io.audio;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.io.audio = {
    enable = mkEnableOpt "Whether to enable audio related tools, default as pipewire";
    enableApps = mkEnableOpt "Whether to enable audio control related packages";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        pipewire = [ "basic" ];
      };
    }
    (mkIf cfg.enableApps {
      modules.singleton = {
        playerctl = [ "basic" ];
        cava = [ "basic" ];
      };
    })
  ]);
}
