{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yubikey" "disabled"

{
  runtime.control.yubikey.disabled = lib.mkDefault true;
}
