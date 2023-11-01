{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "libreoffice" "disabled"

{
  runtime.control.libreoffice.disabled = lib.mkDefault true;
}
