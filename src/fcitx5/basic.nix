{ config, pkgs, lib, ... }:

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
