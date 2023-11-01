{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.social;
  inherit (lib.mine) mkEnableOpt mkOpt';
in {
  options.modules.general.social = {
    enable = mkEnableOpt "Whether to enable socialisation packages";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      discord = [ "basic" ];
      qq = [ "basic" ];
      tdesktop = [ "basic" ];
    };
  };
}
