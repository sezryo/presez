{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "anki" "disabled"

{
  runtime.control.anki.disabled = lib.mkDefault true;
}
