{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "python311" "disabled"

{
  runtime.control.python311.disabled = lib.mkDefault true;
}
