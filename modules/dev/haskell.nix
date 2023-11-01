{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.haskell;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.haskell = {
    enable = mkEnableOpt "Whether to enable haskell toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      stack = [ "basic" ];
      cabal-install = [ "basic" ];
      ghc = [ "basic" ];
    };
  };
}
