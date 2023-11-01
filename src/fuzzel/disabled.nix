{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "fuzzel" "disabled"

{
  runtime.control.fuzzel.disabled = lib.mkDefault true;
}
