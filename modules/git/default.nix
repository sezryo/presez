{ pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    delta.enable = true;

    userName = "Sezriv";
    userEmail = "sezrienne@proton.me";

    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
