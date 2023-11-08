{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ventoy" "basic"

{
  home.packages = [ pkgs.ventoy-full ];
}
