{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wev" "disabled"

{
  runtime.control.wev.disabled = lib.mkDefault true;
}
