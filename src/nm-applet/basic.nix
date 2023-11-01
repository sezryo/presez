{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nm-applet" "basic"

{
  home.programs.nm-applet = {
    enable = true;
  };
}
