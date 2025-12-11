{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.desktop.cursor;
  inherit (lib.mine) mkEnableOpt mkOpt';
  themes = [ "catppuccin" ];
in {
  options.modules.desktop.cursor = mkOpt' (enum themes) "catppuccin" "Choose which cursor theme to use, default is catppuccin";

  config = mkMerge [
    (mkIf (cfg == "catppuccin") {
      home.pointerCursor = {
        package = pkgs.catppuccin-cursors.frappeLavender;
        name = "catppuccin-frappe-lavender-cursors";
        size = 24;
        gtk.enable = true;
	x11.enable = true;
      };
      modules.singleton.gtk = mkDefault [ "catppuccin" ];
    })
  ];
}
