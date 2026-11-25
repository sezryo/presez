{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.nodejs_24 ];
  # environment.sessionVariables = rec {
  #   NODE_OPTIONS = "--openssl-legacy-provider"; 
  # };
}
