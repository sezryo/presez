{ config, pkgs, inputs, lib, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.users.home;
  inherit (lib.mine) mkEnableOpt' mkOpt mkOpt' mkOptStr;
in {
  options = {
    modules.users.home = {
      enable = mkEnableOpt' "Whether to manager user files wisely";
    };
    
    home = {
      programs = mkOpt attrs {};
      packages = mkOpt (listOf package) [];
      services = mkOpt attrs {};
      qt = mkOpt attrs {};
      gtk = mkOpt attrs {};
      desktopEntries = mkOpt attrs {};
      sessionVariables = mkOpt attrs {};
      mimeApps = mkOpt attrs {};
      activation = mkOpt attrs {};
      dconf = mkOpt attrs {};
      pointerCursor = mkOpt attrs {};
      file       = mkOpt' attrs {} "Files to place directly in $HOME";
      configFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
      dataFile   = mkOpt' attrs {} "Files to place in $XDG_DATA_HOME";
    };
  };

  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
      
      #   home.file           ->  home-manager.users.<user>.home.file
      #   home.configFile     ->  home-manager.users.<user>.home.xdg.configFile
      #   home.dataFile       ->  home-manager.users.<user>.home.xdg.dataFile
      #   home.mimeApps       ->  home-manager.users.<user>.home.xdg.mimeApps
      #   home.desktopEntries ->  home-manager.users.<user>.home.xdg.desktopEntries
      #   home.<others>       ->  home-manager.users.<user>.home.<others>
      
      
      users.${config.user.name} = {
        
        home = {
          file = mkAliasDefinitions options.home.file;
          sessionVariables = mkAliasDefinitions options.home.sessionVariables;
          stateVersion = config.system.stateVersion;
          username = config.user.name;
          pointerCursor = mkAliasDefinitions options.home.pointerCursor;
          activation = mkAliasDefinitions options.home.activation;
          homeDirectory = config.user.homeDir;
          packages = mkAliasDefinitions options.home.packages;
        };
        
        programs = mkAliasDefinitions options.home.programs;
        services = mkAliasDefinitions options.home.services;
        qt = mkAliasDefinitions options.home.qt;
        dconf = mkAliasDefinitions options.home.dconf;
        gtk = mkAliasDefinitions options.home.gtk;
        xdg = {
          enable = true;
          cacheHome = config.user.cacheDir;
          configHome = config.user.configDir;
          dataHome = config.user.dataDir;
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile   = mkAliasDefinitions options.home.dataFile;
          mimeApps   = mkAliasDefinitions options.home.mimeApps;
          desktopEntries = mkAliasDefinitions options.home.desktopEntries;
        };
      };
    };
  };
}
