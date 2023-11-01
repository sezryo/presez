{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pipewire" "disabled"

{
  runtime.control.pipewire.disabled = lib.mkDefault true;
}
