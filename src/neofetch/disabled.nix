{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "neofetch" "disabled"

{
  runtime.control.neofetch.disabled = lib.mkDefault true;
}
