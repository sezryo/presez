{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.scala;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.scala = {
    enable = mkEnableOpt "Whether to enable scala toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      scala = [ "basic" ];
    };
  };
}
