{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "networkmanagerapplet" "disabled"

{
  runtime.control.networkmanagerapplet.disabled = lib.mkDefault true;
}
