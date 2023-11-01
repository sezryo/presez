{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tlp" "disabled"

{
  runtime.control.tlp.disabled = lib.mkDefault true;
}
