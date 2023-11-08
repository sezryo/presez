{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "proxychains" "basic"

{
  programs.proxychains.enable = true;
}
