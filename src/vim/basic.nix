{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "vim" "basic"

{
  environment.systemPackages = [ pkgs.vim ];
}
