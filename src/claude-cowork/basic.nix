{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.claude-cowork.nixosModules.default ];

  services.claude-cowork = {
    enable = true;
    package = inputs.claude-cowork.packages.${pkgs.stdenv.hostPlatform.system}.claude-cowork-service;
  };
}
