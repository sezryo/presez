{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gcc" "disabled"

{
  runtime.control.gcc.disabled = lib.mkDefault true;
}
