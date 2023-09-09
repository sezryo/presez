{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib.mine) rakeLeaves;
  modules = rakeLeaves ../../modules;
  systemFiles = with modules.system; [
    # System
    dconf sddm udev pcre auto-cpufreq powertop upower dbus gnumake udisks
    
    # Basic
    xonsh vim wget firefox binutils coreutils cpufrequtils pciutils findutils gawk wezterm
    
    # Security
    gpg pcscd agenix

    # Desktop Environment
    qt blueman light
  ];
  devFiles = with modules.dev; [
    c.configuration
    emacs.configuration
    git.configuration
  ];

in {
  imports = systemFiles ++ devFiles;
}
