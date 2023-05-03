{ pkgs, config, lib, ... }:

{
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    dpi = 160;
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        scrollMethod = "twofinger";
        naturalScrolling = true;
        middleEmulation = true;
      };
    };
  };
  xdg.portal = {
    enable = true;
    # extraPortals = with pkgs; [
    #   xdg-desktop-portal-hyprland
    # ];
  };
}
