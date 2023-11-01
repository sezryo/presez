{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "anki" "basic"

{
  home.packages = with pkgs; [ anki ];
}
