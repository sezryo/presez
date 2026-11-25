{ config, lib, pkgs, inputs, ... }:

{
  # services.polybar = {
  #   enable = true;
  # };

  environment.systemPackages = [ pkgs.polybar ];
}
