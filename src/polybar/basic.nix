{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "polybar" "basic"

{
  # services.polybar = {
  #   enable = true;
  # };

  environment.systemPackages = [ pkgs.polybar ];
}
