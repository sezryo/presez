{ config, lib, pkgs, inputs, ... }:

{
  services.flatpak = {
    enable = true;
  };
}
