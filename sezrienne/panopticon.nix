{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  security.sudo.wheelNeedsPassword = false;
}
