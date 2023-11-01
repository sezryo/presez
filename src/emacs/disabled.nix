{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "emacs" "disabled"

{
  runtime.control.emacs.disabled = lib.mkDefault true;
}
