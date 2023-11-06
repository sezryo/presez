{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules.singleton "fcitx5" "disabled"

{
  runtime.control.fcitx5.disabled = lib.mkDefault true;
}
