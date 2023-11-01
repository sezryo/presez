{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "procs" "disabled"

{
  runtime.control.procs.disabled = lib.mkDefault true;
}
