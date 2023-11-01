{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.scheme;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.scheme = {
    enable = mkEnableOpt "Whether to enable scheme toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      scheme48 = [ "basic" ];
    };
  };
}
