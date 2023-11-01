{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.security.tpm;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.security.tpm = {
    enable = mkEnableOpt "Whether to enable tpm settings";
  };

  config = mkIf cfg.enable {
    security = {
      tpm2 = {
        enable = true;
        pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
        tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
      };
    };
    users.users.${config.user.name}.extraGroups = [ "tss" ];
  };
}
