{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "hdapsd" "disabled"

{
  runtime.control.hdapsd.disabled = lib.mkDefault true;
}
