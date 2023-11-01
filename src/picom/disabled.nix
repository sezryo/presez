{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "picom" "disabled"

{
  runtime.control.picom.disabled = lib.mkDefault true;
}
