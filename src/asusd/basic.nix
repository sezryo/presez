{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "asusd" "basic"

{
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
}
