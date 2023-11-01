{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "scheme48" "disabled"

{
  runtime.control.scheme48.disabled = lib.mkDefault true;
}
