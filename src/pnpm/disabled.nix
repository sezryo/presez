{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pnpm" "disabled"

{
  runtime.control.pnpm.disabled = lib.mkDefault true;
}
