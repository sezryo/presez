{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "win-virtio" "basic"

{
  environment.systemPackages = [ pkgs.win-virtio ];
}
