{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "fstrim" "disabled"

{
  runtime.control.fstrim.disabled = lib.mkDefault true;
}
