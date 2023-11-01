{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "thc-hydra" "disabled"

{
  runtime.control.thc-hydra.disabled = lib.mkDefault true;
}
