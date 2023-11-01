{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "elixir" "basic"

{
  home.packages = [ pkgs.elixir ];
}
