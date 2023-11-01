{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "texlive" "basic"

{
  home.packages = [ pkgs.texlive.combined.scheme-full ];
}
