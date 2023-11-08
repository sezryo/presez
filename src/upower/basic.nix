{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "upower" "basic"

{
  services.upower = {
    enable = true;
  };
}
