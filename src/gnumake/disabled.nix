{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnumake" "disabled"

{
  runtime.control.gnumake.disabled = lib.mkDefault true;
}
