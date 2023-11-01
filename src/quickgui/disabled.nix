{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "quickgui" "disabled"

{
  runtime.control.quickgui.disabled = lib.mkDefault true;
}
