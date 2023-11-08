{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ddgr" "basic"

{
  home.packages = with pkgs; [ ddgr ];
}
