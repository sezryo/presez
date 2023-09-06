{ pkgs, lib, osConfig, ... }:

{
  programs.git = {
    userName = "${osConfig.sez.userName}";
    userEmail = "${osConfig.sez.email}";
    signing = {
      key = "D931EC7A9950B57B";
      signByDefault = true;
    };    
  };
}
