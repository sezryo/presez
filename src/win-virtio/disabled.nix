{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "win-virtio" "disabled"

{
  runtime.control.win-virtio.disabled = lib.mkDefault true;
}
