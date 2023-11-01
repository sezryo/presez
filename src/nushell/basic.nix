{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nushell" "basic"

{
  home.programs.nushell = {
    enable = true;
  };
}
