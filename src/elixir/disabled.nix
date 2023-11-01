{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "elixir" "disabled"

{
  runtime.control.elixir.disabled = lib.mkDefault true;
}
