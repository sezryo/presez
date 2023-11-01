{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "awscli2" "disabled"

{
  runtime.control.awscli2.disabled = lib.mkDefault true;
}
