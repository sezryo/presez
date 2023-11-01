{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "unzip" "disabled"

{
  runtime.control.unzip.disabled = lib.mkDefault true;
}
