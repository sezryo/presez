{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.io.media;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.io.media = {
    enable = mkEnableOpt "Whether to enable modulised media services management";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      ffmpeg = [ "basic" ];
      xvidcore = [ "basic" ];
      vlc = [ "basic" ];
    };
  };
}
