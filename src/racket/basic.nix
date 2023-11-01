{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "racket" "basic"

{
  home.packages = [ pkgs.racket ];
}
