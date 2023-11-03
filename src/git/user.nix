{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "git" "user"

{
  home.programs.git = {
    userName = "${config.user.devName}";
    userEmail = "${config.user.email}";
    signing = {
      key = "${config.user.defaultPublicKey}";
      signByDefault = true;
    };    
  };
}
