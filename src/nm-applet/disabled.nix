{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nm-applet" "disabled"

{
  runtime.control.nm-applet.disabled = lib.mkDefault true;
}
