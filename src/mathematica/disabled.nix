{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "mathematica" "disabled"

{
  runtime.control.mathematica.disabled = lib.mkDefault true;
}
