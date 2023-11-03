{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.desktop.qt;
  inherit (lib.mine) mkEnableOpt mkOpt';
  themes = [ "catppuccin" ];
in {
  options.modules.desktop.qt = {
    enable = mkEnableOpt "Whether to enable QT toolchains";
    theme = mkOpt' (enum themes) "catppuccin" "Choose which QT theme to use, default is catppuccin";
  };
  
  config = mkMerge [
    {
      modules.singleton.qt = [ "basic" ];
    }
    (mkIf (cfg.theme == "catppuccin") {
      modules.singleton.qt = [ "catppuccin" ];
    })
  ];
}
