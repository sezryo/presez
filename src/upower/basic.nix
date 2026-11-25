{ config, lib, pkgs, inputs, ... }:

{
  services.upower = {
    enable = true;
  };
}
