{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "firefox" "disabled"

{
  runtime.control.firefox.disabled = lib.mkDefault true;
}
