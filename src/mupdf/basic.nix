{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "mupdf" "basic"

{
  home.packages = with pkgs; [ mupdf ];
}
