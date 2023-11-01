{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "blueman" "basic"

{
  services.blueman = {
    enable = true;
  };
}
