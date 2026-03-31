{ config, pkgs, lib, inputs, options, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.types) int;
  inherit (lib.mine) mkOpt mkEnableOpt;

  cfg = config.modules.io.monitor;
in {
  options = {
    modules.io.monitor = {
      enable = mkEnableOpt "Whether to enable monitor controlling related tools";
    };
    runtime.monitors = mkOpt int 1;
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      brightnessctl = [ "basic" ];
    };
  };
}
