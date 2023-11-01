{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.pdf;
  inherit (lib.mine) mkEnableOpt mkOpt';
in {
  options.modules.general.pdf = {
    enable = mkEnableOpt "Whether to enable pdf related utilities";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      mupdf = [ "basic" ];
      briss = [ "basic" ];
      okular = [ "basic" ];
      ocrmypdf = [ "basic" ];
    };
  };
}
