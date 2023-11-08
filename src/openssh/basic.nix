{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "openssh" "basic"

{
  services.openssh = {
    enable = true;
  };
}
