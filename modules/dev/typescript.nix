{ config, pkgs, lib, inputs, options, ... }:

# Since Typescript is a superset for Javascript, the latter ones' environment is included here.
with lib;
with lib.types;
let
  cfg = config.modules.dev.typescript;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.typescript = {
    enable = mkEnableOpt "Whether to enable typescript toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      yarn = [ "basic" ];
      yarn2nix = [ "basic" ];
      nodejs = [ "basic" ];
      pnpm = [ "basic" ];
    };
  };
}
