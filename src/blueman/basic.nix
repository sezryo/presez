{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "blueman" "basic"

{
  services.blueman = {
    enable = true;
  };
}
