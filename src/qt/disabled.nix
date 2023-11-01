{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "qt" "disabled"

{
  runtime.control.qt.disabled = lib.mkDefault true;
}
