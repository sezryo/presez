{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "fcitx5" "rime"

{
  i18n = {
    inputMethod = {
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        qt6Packages.fcitx5-chinese-addons
      ];
    };
  };
  # home.packages = [ pkgs.fcitx5-rime ];
}
