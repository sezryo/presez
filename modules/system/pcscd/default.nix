{ pkgs, lib, ... }:

{
  services.pcscd = {
    enable = true;
  };
}