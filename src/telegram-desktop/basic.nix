{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "telegram-desktop" "basic"

{
  home.packages = [ pkgs.telegram-desktop ];
}
