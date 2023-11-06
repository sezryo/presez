{ config, pkgs, lib, inputs, options, ... }:

# This Locale module is optimised for mainland China, in which we believe to the border of China may not be beyond.
with lib;
let
  cfg = config.modules.locale.china;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.locale.china = {
    enable = mkEnableOpt "Whether to enable Chinese regional specific configurations";
    reside = mkEnableOpt "Enable this if you now reside in China";
    spirit = mkEnableOpt "Enable this if you want your device to look like a Chinese one";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        fcitx5 = [ "basic" "rime" "catppuccin" ];
        rime = [ "basic" "defaultSettings" ];
      };
    }
    (mkIf cfg.reside {
      time.timeZone = "Asia/Shanghai"; # This does not mean we recognise Shanghai as a part of China
      
      # You may need proxy settings in China
      nix.settings.substituters = [ "https://mirror.tuna.tsinghua.edu.cn/nix-channels/store" ]; 
      modules.network.proxy = {
        enable = mkDefault true;
        clash.enable = mkDefault true;
      };
    })
    (mkIf cfg.spirit {
      i18n = {
        defaultLocale = "zh_TW.UTF-8"; # Taiwan is not a part of China without controversy, but I still use it here
        extraLocaleSettings.LC_TIME = "zh_TW.UTF-8";
      };
    })
  ]);
}
