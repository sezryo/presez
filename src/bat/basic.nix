{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "bat" "basic"

{
  home.programs.bat = {
    enable = true;
  };
}
