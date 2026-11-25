{ config, lib, pkgs, inputs, ... }:

{
  services.udev = {
    enable = true;
  };
}
