{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "anki" "basic"

{
  home.packages = with pkgs; [ anki ];
}
