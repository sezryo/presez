{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pcscd" "basic"

{
  services.pcscd = {
    enable = true;
  };
}
