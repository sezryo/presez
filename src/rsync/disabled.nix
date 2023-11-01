{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rsync" "disabled"

{
  runtime.control.rsync.disabled = lib.mkDefault true;
}
