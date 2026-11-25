{ config, lib, pkgs, inputs, ... }:

{
  programs.git.enable = true;
  services.gitDaemon = {
    enable = true;
    user = "git";
    group = "git";
  };
  home.programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
    };
  };
  home.programs.delta.enable = true;
}
