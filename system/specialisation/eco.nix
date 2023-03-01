{ pkgs, lib, config, ... }:

let
  cfg = config.eco;

in {
  options.eco.enable = with lib;
    mkEnableOption "Low energy usage";

  config = lib.mkIf cfg.enable {
    services.supergfxd.settings = lib.modules.importJSON ../../modules/supergfxd/eco.conf;
  };
}
