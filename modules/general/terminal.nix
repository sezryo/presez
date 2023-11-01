{ config, pkgs, lib, inputs, options, ... }:

with lib;
with builtins;
with lib.types;

let
  cfg = config.modules.general.terminal;
  inherit (lib.mine) mkEnableOpt mkEnableOpt' mkOpt';
  shells = [ "alacritty" "wezterm" ];
  
in {
  options.modules.general.terminal = {
    enable = mkEnableOpt' "Use modualised options to manage terminal emulator preferences";
    env = mkOpt' (listOf (enum shells)) [ "wezterm" ] "Which terminals to use in total";
    defaultTerminal = mkOpt' (enum shells) "wezterm" "Which terminal to use as default";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        ${cfg.defaultTerminal} = mkDefault [ "basic" ];
      };
    }
    (mkIf (elem "alacritty" cfg.env) {
      modules.singleton = {
        alacritty = [ "basic" "defaultSettings" ];
      };
    })
    (mkIf (elem "wezterm" cfg.env) {
      modules.singleton = {
        wezterm = [ "basic" "defaultSettings" ];
      };
    })
  ]);
}
