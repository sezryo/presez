{ config, lib, pkgs, inputs, ... }:

{
  services.asusd = {
    enable = true;
  };
}
