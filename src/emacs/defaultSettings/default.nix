{ config, lib, pkgs, inputs, ... }:

let
  myEmacs = (pkgs.emacsWithPackagesFromUsePackage {
    config = ./inits/init.el;
    # defaultInitFile = true;
    alwaysEnsure = true;
    package = pkgs.emacs-pgtk;
    # override = epkgs: epkgs // {};
  });
in rec {
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
    file.".emacs.d" = {
      source = ./inits;
      recursive = true;
    };
  };
}
  
