{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tdesktop" "disabled"

{
  runtime.control.tdesktop.disabled = lib.mkDefault true;
}
