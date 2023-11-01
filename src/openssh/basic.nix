{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "openssh" "basic"

{
  services.openssh = {
    enable = true;
  };
}
