{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "imagemagick" "disabled"

{
  runtime.control.imagemagick.disabled = lib.mkDefault true;
}
