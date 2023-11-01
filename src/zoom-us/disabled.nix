{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zoom-us" "disabled"

{
  runtime.control.zoom-us.disabled = lib.mkDefault true;
}
