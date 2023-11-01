{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ripgrep" "disabled"

{
  runtime.control.ripgrep.disabled = lib.mkDefault true;
}
