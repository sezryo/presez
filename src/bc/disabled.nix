{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bc" "disabled"

{
  runtime.control.bc.disabled = lib.mkDefault true;
}
