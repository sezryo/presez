{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "hdapsd" "basic"

{
  services.hdapsd.enable = true;
}
