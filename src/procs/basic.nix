{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "procs" "basic"

{
  home.packages = [ pkgs.procs ];
}
