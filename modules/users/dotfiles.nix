{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.users.dotfiles;
  inherit (lib.mine) mkEnableOpt' mkOpt mkOptStr;
in {
  options = {
    modules.users.dotfiles = {
      enable = mkEnableOpt' "Enable this to add environmental parametres indicating dotfiles paths, useful in reproducible settings per package";
    };
    
    dotfiles = {
      dir = mkOpt path "$HOME/undef"; # New user MUST declare this
      assetsDir = mkOpt path "${config.dotfiles.dir}/assets";
      secretsDir = mkOpt path "${config.dotfiles.dir}/secrets";
      srcDir = mkOpt path "${config.dotfiles.dir}/src";
      binDir = mkOpt path "${config.dotfiles.dir}/bin";
      modulesDir = mkOpt path "${config.dotfiles.dir}/modules";
    };    
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = rec {
      DOTFILES_TOP = "${config.dotfiles.dir}";
      DOTFILES_ASSETS = "${config.dotfiles.assetsDir}";
      DOTFILES_SECRETS = "${config.dotfiles.secretsDir}";
      DOTFILES_MODULES = "${config.dotfiles.modulesDir}";
      DOTFILES_SRC = "${config.dotfiles.srcDir}";
      DOTFILES_BIN = "${config.dotfiles.binDir}";
      PATH = [
        "${DOTFILES_BIN}"
      ];
    };
  };
}
