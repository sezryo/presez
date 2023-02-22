{ pkgs, lib, ... }:

{
  wayland.windowManager.hyprland ={
    enable = true;
    systemdIntegration = true;
    xwayland.enable = true;
    xwayland.hidpi = true;
    extraConfig = builtins.readFile ./myHypr.conf;
  };
}
