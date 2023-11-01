{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "sd" "disabled"

{
  runtime.control.sd.disabled = lib.mkDefault true;
}
