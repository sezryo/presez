{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "proxychains" "basic"

{
  programs.proxychains.enable = true;
}
