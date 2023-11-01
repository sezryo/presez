{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "du-dust" "disabled"

{
  runtime.control.du-dust.disabled = lib.mkDefault true;
}
