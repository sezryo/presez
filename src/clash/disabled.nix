{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "clash" "disabled"

{
  runtime.control.clash.disabled = lib.mkDefault true;
}
