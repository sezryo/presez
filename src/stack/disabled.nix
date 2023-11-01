{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "stack" "disabled"

{
  runtime.control.stack.disabled = lib.mkDefault true;
}
