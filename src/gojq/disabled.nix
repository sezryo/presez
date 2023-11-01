{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gojq" "disabled"

{
  runtime.control.gojq.disabled = lib.mkDefault true;
}
