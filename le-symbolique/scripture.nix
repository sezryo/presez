{ pkgs, config, lib, ... }:

let
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
    sha256 = "sha256:003g02rr7vhz8782d7v6dkvklbax317wj9inb6zi6cglh5zn54kz";
  }) {
    doomPrivateDir = ./scripture-via-crucis;
      emacsPackagesOverlay = self: super: {
        magit-delta = super.magit-delta.overrideAttrs (esuper: {
        buildInputs = esuper.buildInputs ++ [ pkgs.git ];
      });
    }; 
  };
in
{
  programs.emacs = {
    enable = true;
    package = doom-emacs;
  };
}
