{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "git" "disabled"

{
  runtime.control.git.disabled = lib.mkDefault true;
}
