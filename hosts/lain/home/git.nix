{ pkgs, lib, osConfig, ... }:

{
  programs.git = {
    userName = "${osConfig.lain.userName}";
    userEmail = "${osConfig.lain.email}";   
  };
}
