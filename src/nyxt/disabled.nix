{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nyxt" "disabled"

{
  runtime.control.nyxt.disabled = lib.mkDefault true;
}
