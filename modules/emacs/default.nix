{ pkgs, config, lib, ... }:

{
   home.packages = [ pkgs.emacs ];
}

/*
let
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
    sha256 = "sha256:09ic9x3pwah5lspx9prs2zvdskwzawygw6m1mvrgc61b23kjnjq2";
  }) {
    doomPrivateDir = ./.;
      emacsPackagesOverlay = self: super: {
        magit-delta = super.magit-delta.overrideAttrs (esuper: {
        buildInputs = esuper.buildInputs ++ [ pkgs.git ];
      });
    };
  };
in
{
  home.packages = [ doom-emacs ];
}
*/
