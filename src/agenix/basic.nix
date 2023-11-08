{ options, config, lib, pkgs, inputs, ... }:

with lib;
  
let
  secretsFile = "${config.dotfiles.secretsDir}/secrets.nix";
in lib.mine.mkIfProfile config.modules "agenix" "basic"{
  environment.systemPackages = [
    inputs.agenix.packages."${pkgs.system}".default
  ];
  age = {
    secrets = {
      u2f_keys = {
        file = "${config.dotfiles.secretsDir}/u2f_keys.age";
      };
    };
      identityPaths =
        options.age.identityPaths.default ++ (filter pathExists [
        "${config.user.homeDir}/.ssh/id_ed25519"
        "${config.user.homeDir}/.ssh/id_rsa"
      ]);
  };
}
