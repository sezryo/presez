{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zellij" "disabled"

{
  runtime.control.zellij.disabled = lib.mkDefault true;
}
