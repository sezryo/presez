{ pkgs, lib, ... }:

{
  services.udisks2 = {
    enable = true;
  };
}