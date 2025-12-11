{ config, lib, pkgs, inputs, ... }:

let
  myEmacs = pkgs.emacs-pgtk;

in lib.mine.mkIfProfile config.modules "emacs" "doom" rec {
  environment.systemPackages = [ myEmacs ];
  home = {
    services.emacs = {
      package = myEmacs;
      client.enable = true;
      defaultEditor = true;
    };
    programs.emacs = {
      package = myEmacs;
    };
    activation.installDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "${config.user.configDir}/emacs" ]; then
        rm -rf ${config.user.homeDir}/.emacs.d
        echo "Previous emacs configuration disabled."
        ${pkgs.git}/bin/git clone --depth=1 --single-branch "https://github.com/doomemacs/doomemacs" "${config.user.configDir}/emacs"
        echo "Doom Emacs downloaded. Please run 'doom install' in your terminal."
      fi
    '';
    configFile."doom/config.el".source = ./config.el;
    configFile."doom/init.el".source = ./init.el;
    configFile."doom/packages.el".source = ./packages.el;

  };
  environment.sessionVariables = rec {
    # To enable doom as bin utility
    PATH = [ "${config.user.configDir}/emacs/bin" ];
  };
}
  
