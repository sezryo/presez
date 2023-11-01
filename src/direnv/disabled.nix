{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "direnv" "disabled"

{
  runtime.control.direnv.disabled = lib.mkDefault true;
}
