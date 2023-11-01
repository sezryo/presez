{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "vlc" "disabled"

{
  runtime.control.vlc.disabled = lib.mkDefault true;
}
