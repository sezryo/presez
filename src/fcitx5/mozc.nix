{ config, pkgs, lib, ... }:

{
  i18n = {
    inputMethod = {
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
      ];
    };
  };
}
