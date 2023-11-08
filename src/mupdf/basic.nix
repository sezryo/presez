{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "mupdf" "basic"

{
  home.packages = with pkgs; [ mupdf ];
}
