{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.network.ssh;
  inherit (lib.mine) mkEnableOpt mkEnableOpt';
in {
  options.modules.network.ssh = {
    enable = mkEnableOpt "Whether to enable ssh related services";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      openssh = [ "basic" ];
      socat = [ "basic" ];
    };
  };
}
