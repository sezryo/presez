{ pkgs, lib, ... }:

{
  programs.xonsh = {
    enable = true;
    config = "execx($(starship init xonsh))";
  };
}
