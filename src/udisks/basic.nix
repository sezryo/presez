{ config, lib, pkgs, inputs, ... }:

{
  services.udisks2 = {
    enable = true;
  };
}
