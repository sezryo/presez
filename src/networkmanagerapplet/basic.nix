{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "networkmanagerapplet" "basic"

{
  home.packages = [ pkgs.networkmanagerapplet ];
}
