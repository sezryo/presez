{ pkgs, lib, ... }:

{
  services.flatpak = {
    enable = true;
  };
  xdg.portal.enable = true;
}
