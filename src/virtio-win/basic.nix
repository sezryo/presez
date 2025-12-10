{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "virtio-win" "basic"

{
  environment.systemPackages = [ pkgs.virtio-win ];
}
