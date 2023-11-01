{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "chromium" "disabled"

{
  runtime.control.chromium.disabled = lib.mkDefault true;
}
