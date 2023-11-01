{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "electron" "disabled"

{
  runtime.control.electron.disabled = lib.mkDefault true;
}
