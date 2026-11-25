{ config, lib, pkgs, inputs, ... }:

{
  services.displayManager.gdm = {
    enable = true;
  };
}

