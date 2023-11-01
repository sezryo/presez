{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ghc" "disabled"

{
  runtime.control.ghc.disabled = lib.mkDefault true;
}
