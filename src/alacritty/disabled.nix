{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "alacritty" "disabled"

{
  runtime.control.alacritty.disabled = lib.mkDefault true;
}
