{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zathura" "disabled"

{
  runtime.control.zathura.disabled = lib.mkDefault true;
}
