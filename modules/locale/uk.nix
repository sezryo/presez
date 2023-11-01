{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.locale.uk;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.locale.uk = {
    enable = mkEnableOpt "Whether to enable UK regional specific configurations";
    reside = mkEnableOpt "Enable this if you now reside in the UK";
    spirit = mkEnableOpt "Enable this if you want your device to look like a UK one";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      
    }
    (mkIf cfg.reside {
      time.timeZone = "Europe/London";
    })
    (mkIf cfg.spirit {
      i18n = {
        defaultLocale = "en_GB.UTF-8";
        extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
      };
    })
  ]);
}
