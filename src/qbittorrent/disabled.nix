{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "qbittorrent" "disabled"

{
  runtime.control.qbittorrent.disabled = lib.mkDefault true;
}
