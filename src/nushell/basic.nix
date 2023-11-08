{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "nushell" "basic"

{
  home.programs.nushell = {
    enable = true;
  };
}
