{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "okular" "disabled"

{
  runtime.control.okular.disabled = lib.mkDefault true;
}
