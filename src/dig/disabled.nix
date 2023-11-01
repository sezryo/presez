{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dig" "disabled"

{
  runtime.control.dig.disabled = lib.mkDefault true;
}
