{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "xvidcore" "disabled"

{
  runtime.control.xvidcore.disabled = lib.mkDefault true;
}
