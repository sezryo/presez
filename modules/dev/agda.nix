{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.agda;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.agda = {
    enable = mkEnableOpt "Whether to enable agda toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      agda = [ "basic" ];
    };
  };
}
