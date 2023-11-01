{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "findutils" "disabled"

{
  runtime.control.findutils.disabled = lib.mkDefault true;
}
