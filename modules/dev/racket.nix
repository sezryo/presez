{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.racket;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.racket = {
    enable = mkEnableOpt "Whether to enable racket toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      racket = [ "basic" ];
    };
  };
}
