{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nodejs-18_x" "basic"

{
  home.packages = [ pkgs.nodejs-18_x ];
  environment.sessionVariables = rec {
    NODE_OPTIONS = "--openssl-legacy-provider"; 
  };
}
