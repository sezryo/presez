{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "fcitx5" "mozc"

{
  i18n = {
    inputMethod = {
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
      ];
    };
  };
}
