{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bottom" "disabled"

{
  runtime.control.bottom.disabled = lib.mkDefault true;
}
