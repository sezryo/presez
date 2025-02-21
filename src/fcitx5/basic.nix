{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "fcitx5" "basic"

{
  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-table-extra
        fcitx5-lua
      ];
    };
  };
}
