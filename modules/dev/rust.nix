{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.rust;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.rust = {
    enable = mkEnableOpt "Whether to enable rust toolchain";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.rust-overlay.overlays.default
    ];
    modules.singleton = {
      rustc = [ "basic" ];
      cargo = [ "basic" ];
    };
  };
}
