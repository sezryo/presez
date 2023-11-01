{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rtkit" "disabled"

{
  runtime.control.rtkit.disabled = lib.mkDefault true;
}
