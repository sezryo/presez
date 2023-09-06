{ inputs, config, pkgs, lib, ... }:

let
  myEmacs = (pkgs.emacsWithPackagesFromUsePackage {
    config = ./inits/init.el;
    # defaultInitFile = true;
    alwaysEnsure = true;
    package = pkgs.emacs-pgtk;
    # override = epkgs: epkgs // {};
  });
in {
  environment.systemPackages = [ myEmacs ];
}
  
