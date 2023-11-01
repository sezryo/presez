{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.security.u2f;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.security.u2f = {
    enable = mkEnableOpt "Whether to enable u2fauth authentication settings";
    yubikey = mkEnableOpt "Enable this if you have a yubico key";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      security = {
        sudo.wheelNeedsPassword = true;
        pam = {
          services.sudo.u2fAuth = true;
          u2f.authFile = config.age.secrets.u2f_keys.path;
        };
      };
    }
    (mkIf cfg.yubikey {
      security = {
        pam.yubico = {
          enable = true;
          debug = true;
          # control = "required"; # Uncomment to use MFA
          mode = "challenge-response";
          id = config.user.yubikoId;
        };
      };
    })
  ]);
}
