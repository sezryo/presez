{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "fcitx5" "catppuccin"

{
  home.dataFile."fcitx5/themes" = {
    source = ./src;
    recursive = true;
  };
}
