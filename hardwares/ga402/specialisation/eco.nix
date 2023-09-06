{ pkgs, lib, config, ... }:

let
  cfg = config.eco;

in {
  options.eco.enable = with lib;
    mkEnableOption "Low energy usage";

  config = lib.mkIf cfg.enable {
    environment.etc."supergfxd.conf" = {
      source = "${config.dotfiles.systemDir}/supergfxd/eco.conf";
      mode = "0644";
    };
  };
}
