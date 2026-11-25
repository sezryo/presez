{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.beamPackages.elixir ];
}
