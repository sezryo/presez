{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cava" "disabled"

{
  runtime.control.cava.disabled = lib.mkDefault true;
}
