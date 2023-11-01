{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "texlive" "disabled"

{
  runtime.control.texlive.disabled = lib.mkDefault true;
}
