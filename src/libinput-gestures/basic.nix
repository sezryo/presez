{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "libinput-gestures" "basic"

{
  home.packages = [ pkgs.libinput-gestures ];
}
