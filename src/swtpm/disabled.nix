{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "swtpm" "disabled"

{
  runtime.control.swtpm.disabled = lib.mkDefault true;
}
