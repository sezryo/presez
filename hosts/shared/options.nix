{ config, pkgs, inputs, lib, options, ... }:

with lib;
let
  inherit (lib.mine) mkOpt mkOpt' mkOptStr;
in {
  options = with types; {
    user = {
      name = mkOptStr "undef"; # New user MUST declare this
      extraGroups = mkOpt list [ "wheel" ];
      isNormalUser = mkOpt Bool true;     
      home = mkOpt path "/home/${config.user.name}";
      homeCache = mkOpt path "${config.user.home}/.cache";
      homeData = mkOpt path "${config.user.home}/.local/share";
      homeState = mkOpt path "${config.user.home}/.local/state";
      homeConfig = mkOpt path "${config.user.home}/.config";
      group = mkOptStr "users";
      uid = mkOpt int 1000;
      extraConfig = mkOpt attrs {};
    };
    dotfiles = {
      dir = mkOpt path "$HOME/undef"; # New user MUST declare this
      assetsDir = mkOpt path "${config.dotfiles.dir}/assets";
      secretsDir = mkOpt path "${config.dotfiles.dir}/secrets";
      devDir = mkOpt path "${config.dotfiles.dir}/modules/dev";
      shelterDir = mkOpt path "${config.dotfiles.dir}/modules/shelter";
      systemDir = mkOpt path "${config.dotfiles.dir}/modules/system";
      sharedDir = mkOpt path "${config.dotfiles.dir}/hosts/shared";
      myDir = mkOpt path "${config.dotfiles.dir}/hosts/${config.user.name}";
    };
  };
}
