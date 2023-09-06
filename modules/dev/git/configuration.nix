{ config, pkgs, lib, inputs, ... }:

{
  programs.git.enable = true;
  services.gitDaemon = {
    enable = true;
    user = "git";
    group = "git";
  };
}
