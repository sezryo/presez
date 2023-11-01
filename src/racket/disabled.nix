{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "racket" "disabled"

{
  runtime.control.racket.disabled = lib.mkDefault true;
}
