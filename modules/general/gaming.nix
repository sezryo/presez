{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.gaming;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.general.gaming = {
    enable = mkEnableOpt "Whether to install modualised gaming compatitors";
    gamescope = mkEnableOpt "Whether to use gamescope as steam launching scheme";
    emulators = mkEnableOpt "Whether to install gaming emulators";
    osu = mkEnableOpt "Whether to enable osu bundles";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        steam = [ "basic" ];
      };
    }
    (mkIf cfg.gamescope {
      modules.singleton = {
        gamescope = [ "basic" ];
        steam = [ "gamescope" "steam-deck" ];
      };
      modules.desktop.wayland.enable = mkDefault true;
    })
    (mkIf cfg.emulators {
      modules.singleton = {
        bottles = [ "basic" ];
        # yuzu-early-access = [ "basic" ]; # Shame on Nintendo
      };
    })
    (mkIf cfg.osu {
      modules.singleton = {
        osu-lazer = [ "basic" ];
      };
    })
  ]);
}
