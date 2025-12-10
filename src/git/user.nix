{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "git" "user"

{
  home.programs.git = {
    settings.user.name = "${config.user.devName}";
    settings.user.email = "${config.user.email}";
    signing = {
      key = "${config.user.defaultPublicKey}";
      signByDefault = true;
    };    
  };
}
