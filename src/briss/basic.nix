{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "briss" "basic"

{
  home.packages = with pkgs; [ briss ];
}
