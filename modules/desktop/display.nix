{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.desktop.display;
  inherit (lib.mine) mkEnableOpt mkOpt';
  dms = [ "gdm" "sddm" "sddm-corners" ];
in {
  options.modules.desktop.display = {
    enable = mkEnableOpt "Whether to use a display manager, useful to toggle off when only need tty";
    package = mkOpt' (enum dms) "sddm-corners" "Choose which display manager to use, themes may apply";
  };

  config = mkIf cfg.enable (mkMerge [   
    (mkIf (cfg.package == "gdm") {
      modules.singleton.gdm = [ "basic" ];
    })
    (mkIf (cfg.package == "sddm") {
      modules.singleton.sddm = [ "basic" ];
    })
    (mkIf (cfg.package == "sddm-corners") {
      modules.singleton.sddm = [ "basic" "corners" ];
    })
  ]);
}
