{ config, pkgs, inputs, lib, options, ... }:

with lib;
let
  inherit (lib.mine) mkOpt mkOpt' mkOptStr;
in {
  options = with types; {
    user = mkOpt attrs {};
    dotfiles = {
      dir = mkOpt path
        (removePrefix "/mnt"
          (findFirst pathExists (toString ../../.) [
            "/mnt/etc/dotfiles"
            "/etc/dotfiles"
            "/mnt/etc/presez"
            "/etc/presez"
          ]));
      assetsDir = mkOpt path "${config.dotfiles.dir}/assets";
      secretsDir = mkOpt path "${config.dotfiles.dir}/secrets";
      devDir = mkOpt path "${config.dotfiles.dir}/modules/dev";
      shelterDir = mkOpt path "${config.dotfiles.dir}/modules/shelter";
      systemDir = mkOpt path "${config.dotfiles.dir}/modules/system";
      sharedDir = mkOpt path "${config.dotfiles.dir}/hosts/shared";
      myDir = mkOpt path "${config.dotfiles.dir}/hosts/${config.user.name}";
    };
  };

  config = {
    user =
      let user = builtins.getEnv "USER";
          name = if elem user [ "" "root" ] then "sezrienne" else user;
      in {
        inherit name;
        description = "The primary sez's account";
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        home = "/home/${name}";
        group = "users";
        uid = 1000;
      };
  };
}
