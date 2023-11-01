{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ocrmypdf" "disabled"

{
  runtime.control.ocrmypdf.disabled = lib.mkDefault true;
}
