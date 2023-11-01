{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wlogout" "disabled"

{
  runtime.control.wlogout.disabled = lib.mkDefault true;
}
