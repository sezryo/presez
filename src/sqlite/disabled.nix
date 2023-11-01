{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "sqlite" "disabled"

{
  runtime.control.sqlite.disabled = lib.mkDefault true;
}
