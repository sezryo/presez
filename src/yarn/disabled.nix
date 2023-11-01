{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yarn" "disabled"

{
  runtime.control.yarn.disabled = lib.mkDefault true;
}
