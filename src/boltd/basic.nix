{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "boltd" "basic"

{
  services.hardware.bolt.enable = true;
}
