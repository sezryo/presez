{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "pueue" "basic"

{
  home.services.pueue = {
    enable = true;
  };
}
