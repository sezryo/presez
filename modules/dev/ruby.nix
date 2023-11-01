{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.ruby;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.ruby = {
    enable = mkEnableOpt "Whether to enable ruby toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      ruby = [ "basic" ];
    };
  };
}
