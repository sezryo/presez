{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.git;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.git = {
    enable = mkEnableOpt "Whether to enable git toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      git = [ "basic" "user" ];
      gh = [ "basic" ];
    };
  };
}
