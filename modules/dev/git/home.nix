{ pkgs, lib, ... }:

{
  imports = [
    ./github.nix
  ];
  programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
