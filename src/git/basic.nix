{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "git" "basic"

{
  programs.git.enable = true;
  services.gitDaemon = {
    enable = true;
    user = "git";
    group = "git";
  };
  home.programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
