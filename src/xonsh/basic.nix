{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "xonsh" "basic"

{
  programs.xonsh = {
    enable = true;
    config = lib.mkIf (config.modules.singleton.starship != []) "execx($(starship init xonsh))";
  };
}
