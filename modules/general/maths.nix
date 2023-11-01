{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.maths;
  inherit (lib.mine) mkEnableOpt mkOpt';
in {
  options.modules.general.maths = {
    enable = mkEnableOpt "Whether to enable mathematics toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      # mathematica = [ "basic" ];
      bc = [ "basic" ];
      gnuplot = [ "basic" ];
    };
  };
}
