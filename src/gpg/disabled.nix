{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gpg" "disabled"

{
  runtime.control.gpg.disabled = lib.mkDefault true;
}
