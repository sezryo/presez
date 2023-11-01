{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "poppler_utils" "disabled"

{
  runtime.control.poppler_utils.disabled = lib.mkDefault true;
}
