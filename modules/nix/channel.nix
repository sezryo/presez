{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;

let
  cfg = config.modules.nix.channel;
  inherit (lib.mine) mkEnableOpt mkOpt mkOpt';
  channels = [ "latest" "unstable" "stable" ];
in {
  options = {
    modules.nix.channel = mkOpt' (enum channels) "unstable" "Which nixpkgs channel to use";
    runtime.channel = mkOpt str "unstable";
  };

  config = mkMerge [
    # TODO: Make a nixpkgs flake input alternating utility
    {
      runtime.channel = cfg;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = true;
      nixpkgs.overlays = [
        inputs.nur.overlays.default
      ];
    }
    (mkIf (cfg == "unstable" || cfg == "latest") {
      nix = {
        package = pkgs.nixVersions.latest;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
    })
  ];
}
