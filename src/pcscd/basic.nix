{ config, lib, pkgs, inputs, ... }:

{
  services.pcscd = {
    enable = true;
  };
}
