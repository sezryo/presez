{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yewtube" "disabled"

{
  runtime.control.yewtube.disabled = lib.mkDefault true;
}
