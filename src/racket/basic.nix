{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "racket" "basic"

{
  home.packages = [ pkgs.racket ];
}
