{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "newsflash" "basic"

{
  home.packages = [ pkgs.newsflash ];
}
