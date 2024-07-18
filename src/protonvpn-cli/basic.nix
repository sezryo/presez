{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "protonvpn-cli" "basic"

{
  home.packages = [ pkgs.protonvpn-cli ];
}
