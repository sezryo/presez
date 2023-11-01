{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "starship" "disabled"

{
  runtime.control.starship.disabled = lib.mkDefault true;
}
