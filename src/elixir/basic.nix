{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "elixir" "basic"

{
  home.packages = [ pkgs.elixir ];
}
