{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dhall" "disabled"

{
  runtime.control.dhall.disabled = lib.mkDefault true;
}
