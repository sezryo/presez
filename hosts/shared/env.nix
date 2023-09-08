{ config, lib, pkgs, inputs, ... }:

{
  environment = {
    sessionVariables = rec {
      XDG_CACHE_HOME  = "${config.user.homeCache}";
      XDG_CONFIG_HOME = "${config.user.homeConfig}";
      XDG_DATA_HOME   = "${config.user.homeData}";
      XDG_STATE_HOME  = "${config.user.homeState}";

      DOTFILES_TOP = "${config.dotfiles.dir}";
      DOTFILES_ASSETS = "${config.dotfiles.assetsDir}";
      DOTFILES_SECRETS = "${config.dotfiles.secretsDir}";
      DOTFILES_DEV = "${config.dotfiles.devDir}";
      DOTFILES_SHELTER = "${config.dotfiles.shelterDir}";
      DOTFILES_SYSTEM = "${config.dotfiles.systemDir}";
      DOTFILES_SHARED = "${config.dotfiles.sharedDir}";
      DOTFILES_MY = "${config.dotfiles.myDir}";
    };
    etc = {
      home-manager.source = "${inputs.home-manager}";
      nixpkgs.source = "${inputs.nixpkgs}";
      latest.source = "${inputs.latest}";
    };
    # List of acceptable shells in /etc/shells
    shells = with pkgs; [ bash xonsh nushell ];
  };
}
