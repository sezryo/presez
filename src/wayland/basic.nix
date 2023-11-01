{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wayland" "basic"

{
  environment.systemPackages = [ pkgs.wayland ];
}
