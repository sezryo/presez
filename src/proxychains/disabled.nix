{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "proxychains" "disabled"

{
  runtime.control.proxychains.disabled = lib.mkDefault true;
}
