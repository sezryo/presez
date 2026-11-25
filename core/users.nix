{ config, pkgs, lib, inputs, options, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.types) attrs bool int listOf path str;
  inherit (lib.mine) mkEnableOpt' mkOpt mkOptStr;

  cfg = config.modules.users.users;

  # Session variables reach every PAM session, root's under sudo included.
  # Paths inside the user's home are therefore written relative to $HOME, so
  # that root keeps its caches and state in its own home and does not leave
  # root-owned files in this one.
  relativeToHome = path:
    let
      home = "${toString config.user.homeDir}/";
      text = toString path;
    in
      if lib.hasPrefix home text
      then "$HOME/${lib.removePrefix home text}"
      else text;
in {
  options = {
    modules.users.users = {
      enable = mkEnableOpt' "Whether to manage users configuration";
    };

    user = {
      name = mkOptStr null;
      hostName = mkOptStr null;
      fullName = mkOptStr null;
      devName = mkOptStr null;
      email = mkOptStr null;
      academicEmail = mkOptStr null;
      defaultPublicKey = mkOptStr null;
      yubikoId = mkOpt (listOf str) [];

      group = mkOptStr "users";
      isNormalUser = mkOpt bool true;
      uid = mkOpt int 1000;
      extraConfig = mkOpt attrs {};
      extraGroups = mkOpt (listOf str) [ "wheel" "input" ];

      homeDir = mkOpt path "/home/${config.user.name}";
      cacheDir = mkOpt path "${config.user.homeDir}/.cache";
      dataDir = mkOpt path "${config.user.homeDir}/.local/share";
      nixDataDir = mkOpt path "${config.user.homeDir}/.nix-profile/share";
      stateDir = mkOpt path "${config.user.homeDir}/.local/state";
      configDir = mkOpt path "${config.user.homeDir}/.config";
    };
  };

  config = mkIf cfg.enable {
    networking.hostName = config.user.hostName;
    users.users.${config.user.name} = {
      isNormalUser = config.user.isNormalUser;
      extraGroups = config.user.extraGroups;
    };
    environment.sessionVariables = {
      XDG_CACHE_HOME  = relativeToHome config.user.cacheDir;
      XDG_DATA_HOME   = relativeToHome config.user.dataDir;
      XDG_DATA_DIRS   = [ (relativeToHome config.user.nixDataDir) ];
      XDG_STATE_HOME  = relativeToHome config.user.stateDir;
      CURRENT_USER    = "${config.user.name}";
    };
  };
}
