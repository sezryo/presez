{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "quickemu" "disabled"

{
  runtime.control.quickemu.disabled = lib.mkDefault true;
}
