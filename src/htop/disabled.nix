{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "htop" "disabled"

{
  runtime.control.htop.disabled = lib.mkDefault true;
}
