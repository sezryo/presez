{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "utop" "disabled"

{
  runtime.control.utop.disabled = lib.mkDefault true;
}
