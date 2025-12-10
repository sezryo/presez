{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "lunarvim" "basic"

{
  home.packages = [ pkgs.lunarvim ];
}
