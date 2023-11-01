{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pueue" "basic"

{
  home.services.pueue = {
    enable = true;
  };
}
