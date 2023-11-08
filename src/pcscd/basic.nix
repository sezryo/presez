{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "pcscd" "basic"

{
  services.pcscd = {
    enable = true;
  };
}
