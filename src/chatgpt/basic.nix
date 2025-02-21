{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "chatgpt" "basic"

{
  home.packages = [ pkgs.chatgpt ];
}
