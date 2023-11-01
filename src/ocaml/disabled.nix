{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ocaml" "disabled"

{
  runtime.control.ocaml.disabled = lib.mkDefault true;
}
