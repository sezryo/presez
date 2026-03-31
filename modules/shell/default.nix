{ config, pkgs, lib, inputs, options, ... }:

let
  inherit (lib) mkIf mkMerge mkDefault elem;
  inherit (lib.types) listOf enum;
  inherit (lib.mine) mkEnableOpt' mkOpt';

  cfg = config.modules.shell;
  shells = [ "bash" "fish" "nushell" "xonsh" "babashka" ];

in {
  imports = [
    ./integration.nix
    ./tools.nix
  ];

  options.modules.shell = {
    enable = mkEnableOpt' "Use modularised options to manage shell preferences";
    env = mkOpt' (listOf (enum shells)) [ "bash" ] "Which shells to use in total";
    loginShell = mkOpt' (enum shells) "bash" "Which shell to use as login shell";
    defaultShell = mkOpt' (enum shells) "bash" "Which shell to use as default";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        ${cfg.loginShell} = mkDefault [ "basic" ];
        ${cfg.defaultShell} = mkDefault [ "basic" ];
      };
      users.users.${config.user.name}.shell = pkgs.${cfg.loginShell};
    }
    (mkIf (elem "bash" cfg.env) {
      modules.singleton.bash = [ "basic" ];
      environment.shells = [ pkgs.bash ];
    })
    (mkIf (elem "fish" cfg.env) {
      modules.singleton.fish = [ "basic" ];
      environment.shells = [ pkgs.fish ];
    })
    (mkIf (elem "xonsh" cfg.env) {
      modules.singleton.xonsh = [ "basic" ];
      environment.shells = [ pkgs.xonsh ];
    })
    (mkIf (elem "nushell" cfg.env) {
      modules.singleton.nushell = [ "basic" "defaultSettings" ];
      environment.shells = [ pkgs.nushell ];
    })
    (mkIf (elem "babashka" cfg.env) {
      modules.singleton.babashka = [ "basic" ];
    })
  ]);
}
