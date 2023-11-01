{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "briss" "disabled"

{
  runtime.control.briss.disabled = lib.mkDefault true;
}
