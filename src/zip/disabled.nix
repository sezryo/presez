{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zip" "disabled"

{
  runtime.control.zip.disabled = lib.mkDefault true;
}
