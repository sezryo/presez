{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "dropbox" "basic"

{
  home.packages = [ pkgs.dropbox-cli ];
}
