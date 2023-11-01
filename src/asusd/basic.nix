{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "asusd" "basic"

{
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
}
