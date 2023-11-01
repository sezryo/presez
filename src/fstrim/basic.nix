{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "fstrim" "basic"

{
  services.fstrim.enable = true;
}
