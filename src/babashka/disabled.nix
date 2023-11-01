{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "babashka" "disabled"

{
  runtime.control.babashka.disabled = lib.mkDefault true;
}
