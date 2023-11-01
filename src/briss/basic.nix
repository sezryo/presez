{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "briss" "basic"

{
  home.packages = with pkgs; [ briss ];
}
