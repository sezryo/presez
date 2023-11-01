{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "jaq" "disabled"

{
  runtime.control.jaq.disabled = lib.mkDefault true;
}
