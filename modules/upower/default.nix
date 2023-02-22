{ pkgs, lib, ... }:

{
  services.upower = {
    enable = true;
  };
}