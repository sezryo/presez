{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.lm_sensors ];
}