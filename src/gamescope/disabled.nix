{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gamescope" "disabled"

{
  runtime.control.gamescope.disabled = lib.mkDefault true;
}
