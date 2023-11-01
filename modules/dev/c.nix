{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.c;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.c = {
    enable = mkEnableOpt "Whether to enable C-languages toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      gcc = [ "basic" ];
      cmake = [ "basic" ];
    };
  };
}
