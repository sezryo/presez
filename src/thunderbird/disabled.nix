{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "thunderbird" "disabled"

{
  runtime.control.thunderbird.disabled = lib.mkDefault true;
}
