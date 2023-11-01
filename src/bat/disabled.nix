{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bat" "disabled"

{
  runtime.control.bat.disabled = lib.mkDefault true;
}
