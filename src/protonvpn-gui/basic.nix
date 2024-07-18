{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "protonvpn-gui" "basic"

{
  home.packages = [ pkgs.protonvpn-gui ];
}
