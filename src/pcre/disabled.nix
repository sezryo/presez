{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pcre" "disabled"

{
  runtime.control.pcre.disabled = lib.mkDefault true;
}
