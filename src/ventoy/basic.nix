{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ventoy" "basic"

{
  home.packages = [ pkgs.ventoy-full ];
}
