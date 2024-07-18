{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.lean;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.lean = {
    enable = mkEnableOpt "Whether to enable lean toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      lean4 = [ "basic" ];
    };
  };
}
