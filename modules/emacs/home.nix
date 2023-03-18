{ inputs, config, pkgs, lib, ... }:

with ../../functions;

let
  myEmacs = (pkgs.emacsWithPackagesFromUsePackage {
    config = ./inits/init.el;
    # defaultInitFile = true;
    alwaysEnsure = true;
    package = pkgs.emacsPgtk;
    # override = epkgs: epkgs // {};
  });
in rec 
{
  services.emacs = {
    enable = true;
    package = myEmacs;
    client.enable = true;
    defaultEditor = true;
  };
  programs.emacs = {
    enable = true;
    package = myEmacs;
  };
  home.file.".emacs.d" = {
    source = ./inits;
    recursive = true;
  };
  home.packages = with pkgs.emacsPackages; [
    tuareg
  ];
}

