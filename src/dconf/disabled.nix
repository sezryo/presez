{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dconf" "disabled"

{
  runtime.control.dconf.disabled = lib.mkDefault true;
}
