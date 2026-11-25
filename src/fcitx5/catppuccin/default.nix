{ config, pkgs, lib, ... }:

{
  home.dataFile."fcitx5/themes" = {
    source = ./src;
    recursive = true;
  };
}
