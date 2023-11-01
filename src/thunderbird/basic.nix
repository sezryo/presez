{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "thunderbird" "basic"

{
  home.packages = [ pkgs.thunderbird ];
}
