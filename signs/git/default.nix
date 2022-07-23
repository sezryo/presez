{ pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    delta.enable = true;
  };
}
