{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "procs" "basic"

{
  home.packages = [ pkgs.procs ];
}
