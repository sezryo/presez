{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "nixfmt" "basic"

{
  home.packages = [ pkgs.nixfmt ];
}
