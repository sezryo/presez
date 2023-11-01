{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "psmisc" "disabled"

{
  runtime.control.psmisc.disabled = lib.mkDefault true;
}
