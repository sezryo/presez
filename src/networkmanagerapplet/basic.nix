{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "networkmanagerapplet" "basic"

{
  home.packages = [ pkgs.networkmanagerapplet ];
}
