{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "vim" "basic"

{
  environment.systemPackages = [ pkgs.vim ];
}
