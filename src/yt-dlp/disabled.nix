{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yt-dlp" "disabled"

{
  runtime.control.yt-dlp.disabled = lib.mkDefault true;
}
