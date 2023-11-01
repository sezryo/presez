{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "trash-cli" "disabled"

{
  runtime.control.trash-cli.disabled = lib.mkDefault true;
}
