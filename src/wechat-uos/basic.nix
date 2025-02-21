{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "wechat-uos" "basic"

{
  home.packages = [ pkgs.wechat-uos ];
}
