{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "mesa" "disabled"

{
  runtime.control.mesa.disabled = lib.mkDefault true;
}
