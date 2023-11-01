{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "sddm" "disabled"

{
  runtime.control.sddm.disabled = lib.mkDefault true;
}
