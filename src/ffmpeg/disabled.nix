{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ffmpeg" "disabled"

{
  runtime.control.ffmpeg.disabled = lib.mkDefault true;
}
