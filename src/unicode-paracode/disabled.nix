{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "unicode-paracode" "disabled"

{
  runtime.control.unicode-paracode.disabled = lib.mkDefault true;
}
