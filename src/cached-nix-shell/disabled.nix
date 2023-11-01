{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cached-nix-shell" "disabled"

{
  runtime.control.cached-nix-shell.disabled = lib.mkDefault true;
}
