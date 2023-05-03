{ pkgs, lib, colourscheme, ... }:

let
  flake-compat = builtins.fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
    sha256 = "sha256:1prd9b1xx8c0sfwnyzkspplh30m613j42l1k789s521f4kv4c2z2";
  };
  hyprland = (import flake-compat {
    src = builtins.fetchTarball {
      url = "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
      sha256 = "sha256:00vfra9kys93armaiwpi6m72v1pn4lzs7dy3sc9nhfzn253jv6gl";
    };
  }).defaultNix;
in {
  imports = [
    hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    xwayland.enable = true;
    xwayland.hidpi = true;
    extraConfig = builtins.readFile ./myHypr.conf;
  };
}
