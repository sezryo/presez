{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "coq" "basic"

{
  home.packages = [ pkgs.coq ];
}
