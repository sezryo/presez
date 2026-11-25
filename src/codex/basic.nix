{ config, lib, pkgs, inputs, ... }:

let
  # Tracks upstream releases independently of nixpkgs: `yo update codex` (see meta.nix).
  codex = inputs.codex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
  home.packages = [ codex ];

  # Replace the earlier standalone launcher that shadows home.packages on PATH.
  home.file.".local/bin/codex" = {
    source = "${codex}/bin/codex";
    force = true;
  };
}
