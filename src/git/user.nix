{ osConfig, config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "git" "user"

{
  home.programs.git = {
    userName = "${osConfig.user.devName}";
    userEmail = "${osConfig.user.email}";
    signing = {
      key = "${osConfig.user.defaultPublicKey}";
      signByDefault = true;
    };    
  };
}
