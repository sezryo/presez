{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bc" "basic"

{
  home.packages = [ pkgs.bc ];
}
