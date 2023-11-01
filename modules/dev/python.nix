{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.python;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.python = {
    enable = mkEnableOpt "Whether to enable python toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      python311 = [ "basic" ];
    };
  };
}
