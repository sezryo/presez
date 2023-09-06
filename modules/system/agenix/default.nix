{ options, config, pkgs, lib, inputs, ... }:

with lib;
let
  secretsFile = "${config.dotfiles.secretsDir}/secrets.nix";
in {
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
        "${config.user.home}/.ssh/id_ed25519"
        "${config.user.home}/.ssh/id_rsa"
      ]);
  };
}
