{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "opengl" "disabled"

{
  runtime.control.opengl.disabled = lib.mkDefault true;
}
