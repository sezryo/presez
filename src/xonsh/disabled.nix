{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "xonsh" "disabled"

{
  runtime.control.xonsh.disabled = lib.mkDefault true;
}
