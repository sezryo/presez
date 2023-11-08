{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "texlive" "basic"

{
  home.packages = [ pkgs.texlive.combined.scheme-full ];
}
