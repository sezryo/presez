{ pkgs, lib, ... }:

{
  services.pueue = {
    enable = true;
  };
}