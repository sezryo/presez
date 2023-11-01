{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "lsd" "disabled"

{
  runtime.control.lsd.disabled = lib.mkDefault true;
}
