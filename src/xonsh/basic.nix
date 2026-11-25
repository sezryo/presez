{ config, lib, pkgs, inputs, ... }:

{
  programs.xonsh = {
    enable = true;
    config = lib.mkIf (config.modules.singleton.starship != []) "execx($(starship init xonsh))";
  };
}
