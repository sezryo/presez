{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nixfmt" "basic"

{
  home.packages = [ pkgs.nixfmt ];
}
