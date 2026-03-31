{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "claude-code" "basic"

{
  home.packages = [
    inputs.claude-code.packages.${pkgs.system}.default
  ];
}
