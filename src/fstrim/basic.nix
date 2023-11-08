{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "fstrim" "basic"

{
  services.fstrim.enable = true;
}
