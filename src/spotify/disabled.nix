{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spotify" "disabled"

{
  runtime.control.spotify.disabled = lib.mkDefault true;
}
