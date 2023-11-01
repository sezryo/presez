{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ddgr" "basic"

{
  home.packages = with pkgs; [ ddgr ];
}
