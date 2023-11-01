{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "opam" "disabled"

{
  runtime.control.opam.disabled = lib.mkDefault true;
}
