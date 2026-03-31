{ config, pkgs, lib, inputs, options, ... }:

let
  inherit (lib) mkIf mkMerge;
  inherit (lib.mine) mkEnableOpt;

  cfg = config.modules.dev.emacs;
in {
  options.modules.dev.emacs = {
    enable = mkEnableOpt "Whether to enable emacs toolchain";
    defaultEditor = mkEnableOpt "Whether to use emacs as the default editor";
    doom = mkEnableOpt "Whether to use doom-emacs";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nixpkgs.overlays = [
        inputs.emacs-overlay.overlay
      ];
      modules.singleton = {
        emacs = [ "basic" ];
        ispell = [ "basic" ];
        sqlite = [ "basic" ];
        graphviz = [ "basic" ];
        poppler-utils = [ "basic" ];
        tuareg = [ "basic" ];
      };
    }
    (mkIf (!cfg.doom) {
      modules.singleton.emacs = [ "defaultSettings" ];
    })
    (mkIf cfg.doom {
      modules.singleton.emacs = [ "doom" ];
    })
    (mkIf cfg.defaultEditor {
      environment.sessionVariables.EDITOR = "emacsclient -c";
    })
  ]);
}
