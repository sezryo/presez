{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "coreutils" "disabled"

{
  runtime.control.coreutils.disabled = lib.mkDefault true;
}
