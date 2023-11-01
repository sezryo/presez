{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnu-cobol" "disabled"

{
  runtime.control.gnu-cobol.disabled = lib.mkDefault true;
}
