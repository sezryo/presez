{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gawk" "disabled"

{
  runtime.control.gawk.disabled = lib.mkDefault true;
}
