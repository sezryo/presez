{ pkgs, config, lib, ... }:

let
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
    sha256 = "sha256:00kmqz3davv6myiamxwcl6bwmrird94s50kxgpk94hql5k21z3dr";
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
  programs.emacs = {
    enable = true;
    package = doom-emacs;
  };
  # home.packages = [ pkgs.emacsNativeComp ];
}
