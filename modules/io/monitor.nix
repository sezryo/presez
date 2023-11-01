{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.io.monitor;
  inherit (lib.mine) mkOpt mkEnableOpt;
in {
  options = {
    modules.io.monitor = {
      enable = mkEnableOpt "Whether to enable monitor controlling related tools";
    };
    runtime.monitors = mkOpt int 1;
    # TODO: Modualise Hyprland multiple monitors scheme
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      light = [ "basic" ];
      brightnessctl = [ "basic" ];
    };
  };
}
