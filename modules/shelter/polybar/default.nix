{ pkgs, lib, ... }:

{
  # services.polybar = {
  #   enable = true;
  # };

  environment.systemPackages = [ pkgs.polybar ];
}
