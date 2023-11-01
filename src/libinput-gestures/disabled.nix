{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "libinput-gestures" "disabled"

{
  runtime.control.libinput-gestures.disabled = lib.mkDefault true;
}
