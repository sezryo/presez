{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.security.kali;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.security.kali = {
    enable = mkEnableOpt "Whether to enable Kali Linux toolchains";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      thc-hydra = [ "basic" ];
      burpsuite = [ "basic" ];
    };
  };
}
