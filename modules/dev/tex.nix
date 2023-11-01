{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.tex;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.tex = {
    enable = mkEnableOpt "Whether to enable tex toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      texlive = [ "basic" ];
    };
  };
}
