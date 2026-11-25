{ config, lib, pkgs, inputs, ... }:

{
  home.programs.nushell = {
    enable = true;
    loadSessionVariables = false;
  };
}
