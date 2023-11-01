{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "merlin" "disabled"

{
  runtime.control.merlin.disabled = lib.mkDefault true;
}
