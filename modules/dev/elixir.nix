{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.elixir;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.elixir = {
    enable = mkEnableOpt "Whether to enable elixir toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      elixir = [ "basic" ];
    };
  };
}
