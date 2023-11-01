{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rustc" "disabled"

{
  runtime.control.rustc.disabled = lib.mkDefault true;
}
