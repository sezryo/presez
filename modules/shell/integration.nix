{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.shell.integration;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.shell.integration = {
    enable = mkEnableOpt "Whether to enable essential shell integrations for performance";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      zoxide = [ "basic" ];
      fzf = [ "basic" ];
      starship = [ "basic" "catppuccin" ];
      zellij = [ "basic" ];
      direnv = [ "basic" ];
    };
  };
}
