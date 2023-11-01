{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dhall-nix" "disabled"

{
  runtime.control.dhall-nix.disabled = lib.mkDefault true;
}
