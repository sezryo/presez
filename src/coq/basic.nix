{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "coq" "basic"

{
  home.packages = [ pkgs.coq ];
}
