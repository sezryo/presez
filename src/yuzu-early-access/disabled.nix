{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yuzu-early-access" "disabled"

{
  runtime.control.yuzu-early-access.disabled = lib.mkDefault true;
}
