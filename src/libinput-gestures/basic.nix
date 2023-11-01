{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "libinput-gestures" "basic"

{
  home.packages = [ pkgs.libinput-gestures ];
}
