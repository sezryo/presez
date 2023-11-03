{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
with lib.mine;
let
  cfg = config.modules.desktop.display;
  dms = [ "tty" "gdm" "sddm" "sddm-corners" ];
in {
  options.modules.desktop.display = {
    enable = mkEnableOpt' "Enable display manager modules";
    package = mkOpt' (enum dms) null "Choose which display manager to use, themes may apply; enter tty for not using any";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.package == "tty") {
      services.xserver.displayManager.startx.enable = true;
    })
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
