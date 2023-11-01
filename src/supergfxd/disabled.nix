{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "supergfxd" "disabled"

{
  runtime.control.supergfxd.disabled = lib.mkDefault true;
}
