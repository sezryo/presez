{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "coq" "disabled"

{
  runtime.control.coq.disabled = lib.mkDefault true;
}
