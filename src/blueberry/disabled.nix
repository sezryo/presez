{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "blueberry" "disabled"

{
  runtime.control.blueberry.disabled = lib.mkDefault true;
}
