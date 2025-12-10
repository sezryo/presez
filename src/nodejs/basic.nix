{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "nodejs" "basic"

{
  home.packages = [ pkgs.nodejs_24 ];
  # environment.sessionVariables = rec {
  #   NODE_OPTIONS = "--openssl-legacy-provider"; 
  # };
}
