{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bat" "basic"

{
  home.programs.bat = {
    enable = true;
  };
}
