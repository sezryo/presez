{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "newsflash" "basic"

{
  home.packages = [ pkgs.newsflash ];
}
