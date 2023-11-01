{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "steam" "disabled"

{
  runtime.control.steam.disabled = lib.mkDefault true;
}
