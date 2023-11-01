{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "calibre" "disabled"

{
  runtime.control.calibre.disabled = lib.mkDefault true;
}
