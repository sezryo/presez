{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "udisks" "basic"

{
  services.udisks2 = {
    enable = true;
  };
}
