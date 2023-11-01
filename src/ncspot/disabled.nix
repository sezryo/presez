{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ncspot" "disabled"

{
  runtime.control.ncspot.disabled = lib.mkDefault true;
}
