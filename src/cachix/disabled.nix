{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cachix" "disabled"

{
  runtime.control.cachix.disabled = lib.mkDefault true;
}
