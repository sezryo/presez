{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yarn2nix" "disabled"

{
  runtime.control.yarn2nix.disabled = lib.mkDefault true;
}
