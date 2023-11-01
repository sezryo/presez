{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "lf" "disabled"

{
  runtime.control.lf.disabled = lib.mkDefault true;
}
