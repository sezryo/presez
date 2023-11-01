{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dict" "disabled"

{
  runtime.control.dict.disabled = lib.mkDefault true;
}
