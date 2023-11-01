{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.cobol;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.cobol = {
    enable = mkEnableOpt "Whether to enable cobol toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      gnu-cobol = [ "basic" ];
    };
  };
}
