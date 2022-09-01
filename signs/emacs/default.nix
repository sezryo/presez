{ pkgs, config, lib, ... }:

let
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
    sha256 = "sha256:1nipiwiaypcrkrcls20prw28ly24s6dqd77vbmc12326kb1fy2w3";
  }) {
    doomPrivateDir = ./.;
      # emacsPackagesOverlay = self: super: {
        # magit-delta = super.magit-delta.overrideAttrs (esuper: {
        # buildInputs = esuper.buildInputs ++ [ pkgs.git ];
      # });
    # };
  };
in
{
  programs.emacs = {
    enable = true;
    package = doom-emacs;
  };
}
