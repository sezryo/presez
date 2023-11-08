{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "udisks" "basic"

{
  services.udisks2 = {
    enable = true;
  };
}
