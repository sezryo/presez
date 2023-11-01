{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "win-virtio" "basic"

{
  environment.systemPackages = [ pkgs.win-virtio ];
}
