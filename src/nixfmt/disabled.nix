{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nixfmt" "disabled"

{
  runtime.control.nixfmt.disabled = lib.mkDefault true;
}
