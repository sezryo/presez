{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "wayland" "basic"

{
  environment.systemPackages = [ pkgs.wayland ];
}
