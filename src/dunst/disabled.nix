{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dunst" "disabled"

{
  runtime.control.dunst.disabled = lib.mkDefault true;
}
