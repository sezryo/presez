{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tealdeer" "disabled"

{
  runtime.control.tealdeer.disabled = lib.mkDefault true;
}
