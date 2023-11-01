{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "fzf" "disabled"

{
  runtime.control.fzf.disabled = lib.mkDefault true;
}
