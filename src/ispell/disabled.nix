{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ispell" "disabled"

{
  runtime.control.ispell.disabled = lib.mkDefault true;
}
