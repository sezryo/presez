{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cbonsai" "disabled"

{
  runtime.control.cbonsai.disabled = lib.mkDefault true;
}
