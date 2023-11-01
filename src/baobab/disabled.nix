{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "baobab" "disabled"

{
  runtime.control.baobab.disabled = lib.mkDefault true;
}
