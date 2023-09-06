{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  security = {
    sudo.wheelNeedsPassword = true;
    tpm2 = {
      enable = true;
      pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
      tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
    };
  };
}
