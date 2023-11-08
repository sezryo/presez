{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "thunderbird" "basic"

{
  home.packages = [ pkgs.thunderbird ];
}
