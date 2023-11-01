{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "newsflash" "disabled"

{
  runtime.control.newsflash.disabled = lib.mkDefault true;
}
