{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "purescript" "disabled"

{
  runtime.control.purescript.disabled = lib.mkDefault true;
}
