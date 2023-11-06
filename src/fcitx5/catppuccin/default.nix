{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules.singleton "fcitx5" "catppuccin"

{
  home.dataFile."fcitx5/themes" = {
    source = ./src;
    recursive = true;
  };
}
