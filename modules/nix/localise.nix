{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
with builtins;
let
  cfg = config.modules.nix.localise;
  inherit (lib.mine) mkEnableOpt mkOpt';
in {
  options.modules.nix.localise = {
    enable = mkEnableOpt "Whether to localise some repositories";
    repos = mkOpt' (listOf str) [ "home-manager" "nixpkgs" "latest" ] "Indicate which repos to localise, strictly from flake inputs";
  };

  config = mkIf cfg.enable {
    environment.etc =
      listToAttrs (
        map (x: { name = "${x}".source; value = "${inputs.x}";}) cfg.repos);
  };
}
