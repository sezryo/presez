{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "fish" "disabled"

{
  runtime.control.fish.disabled = lib.mkDefault true;
}
