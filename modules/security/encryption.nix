{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.security.encryption;
  inherit (lib.mine) mkEnableOpt;
in {
  options = {
    modules.security.encryption = {
      enable = mkEnableOpt "Whether to enable encryption packages";
      yubikey = mkEnableOpt "Enable this if you have a yubico key";
    };
    runtime.yubikey.enable = mkEnableOpt "State whether a yubikey is inserted";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        gpg = [ "basic" ];
        # agenix = [ "basic" ]; # TODO: address problems
      };
      services.gnome.gnome-keyring.enable = true;
    }
    (mkIf cfg.yubikey {
      runtime.yubikey.enable = true;
      modules.security.u2f.yubikey = mkDefault true;
      modules.singleton = {
        yubikey = [ "basic" ];
        pcscd = [ "basic" ];
        udev = [ "yubikey" ];
      };
    })
  ]);
}
