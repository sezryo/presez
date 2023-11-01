{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.coq;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.coq = {
    enable = mkEnableOpt "Whether to enable coq toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      coq = [ "basic" ];
    };
  };
}
