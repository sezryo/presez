{ pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    delta.enable = true;

    userName = "sezryo";
    userEmail = "sezrienne@proton.me";

    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
