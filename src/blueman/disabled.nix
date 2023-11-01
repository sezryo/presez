{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "blueman" "disabled"

{
  runtime.control.blueman.disabled = lib.mkDefault true;
}
