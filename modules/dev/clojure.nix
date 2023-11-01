{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.clojure;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.clojure = {
    enable = mkEnableOpt "Whether to enable clojure toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      clojure = [ "basic" ];
    };
  };
}
