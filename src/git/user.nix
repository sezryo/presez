{ config, lib, pkgs, inputs, ... }:

{
  home.programs.git = {
    settings.user.name = "${config.user.devName}";
    settings.user.email = "${config.user.email}";
    signing = {
      key = "${config.user.defaultPublicKey}";
      signByDefault = true;
      format = "openpgp";
    };    
  };
}
