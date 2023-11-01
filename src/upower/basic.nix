{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "upower" "basic"

{
  services.upower = {
    enable = true;
  };
}
