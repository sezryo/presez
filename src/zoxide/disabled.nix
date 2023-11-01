{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zoxide" "disabled"

{
  runtime.control.zoxide.disabled = lib.mkDefault true;
}
