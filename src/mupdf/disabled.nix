{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "mupdf" "disabled"

{
  runtime.control.mupdf.disabled = lib.mkDefault true;
}
