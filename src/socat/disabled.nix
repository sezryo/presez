{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "socat" "disabled"

{
  runtime.control.socat.disabled = lib.mkDefault true;
}
