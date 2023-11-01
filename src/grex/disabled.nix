{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "grex" "disabled"

{
  runtime.control.grex.disabled = lib.mkDefault true;
}
