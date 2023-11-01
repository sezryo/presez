{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "vim" "disabled"

{
  runtime.control.vim.disabled = lib.mkDefault true;
}
