{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cabal-install" "disabled"

{
  runtime.control.cabal-install.disabled = lib.mkDefault true;
}
