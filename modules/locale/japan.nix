{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.locale.japan;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.locale.japan = {
    enable = mkEnableOpt "Whether to enable Japanese regional specific configurations";
    reside = mkEnableOpt "Enable this if you now reside in the Japan";
    spirit = mkEnableOpt "Enable this if you want your device to look like a Japanese one";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        fcitx5 = [ "basic" "mozc" ];
      };
    }
    (mkIf cfg.reside {
      time.timeZone = "Asia/Tokyo";
    })
    (mkIf cfg.spirit {
      i18n = {
        defaultLocale = "ja_JP.UTF-8";
        extraLocaleSettings.LC_TIME = "ja_JP.UTF-8";
      };
    })
  ]);
}
