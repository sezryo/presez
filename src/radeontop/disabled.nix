{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "radeontop" "disabled"

{
  runtime.control.radeontop.disabled = lib.mkDefault true;
}
