{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "fd" "disabled"

{
  runtime.control.fd.disabled = lib.mkDefault true;
}
