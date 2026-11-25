{
  description = "core utilities for a well-functioning Linux desktop";
  default = true;
  packages = [
    "gnumake"
    "zenity"
    "cachix"
    "electron"
    "dig"
    "vim"
    "wget"
    "firefox"
    "binutils"
    "coreutils"
    "pciutils"
    # "usbutils" # never had a package under src/, so it was never installed; uncomment to install pkgs.usbutils
    "findutils"
    "libtool"
    "gawk"
    "cached-nix-shell"
    "flatpak"
    "hyfetch"
    "baobab"
  ];
}
