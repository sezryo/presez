{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "nm-applet" "basic"

{
  home.programs.nm-applet = {
    enable = true;
  };
}
