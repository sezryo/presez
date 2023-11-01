{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ruby" "disabled"

{
  runtime.control.ruby.disabled = lib.mkDefault true;
}
