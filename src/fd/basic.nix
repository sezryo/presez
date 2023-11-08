{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "fd" "basic"

{
  home.packages = [ pkgs.fd ];
}
