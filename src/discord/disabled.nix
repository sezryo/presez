{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "discord" "disabled"

{
  runtime.control.discord.disabled = lib.mkDefault true;
}
