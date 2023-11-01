{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "hdapsd" "basic"

{
  services.hdapsd.enable = true;
}
