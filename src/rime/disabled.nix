{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules.singleton "rime" "disabled"

{
  runtime.control.rime.disabled = lib.mkDefault true;
}
