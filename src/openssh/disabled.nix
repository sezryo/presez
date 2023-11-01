{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "openssh" "disabled"

{
  runtime.control.openssh.disabled = lib.mkDefault true;
}
