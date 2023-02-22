{ config, pkgs, lib, ... }:

# These are modules used on Init on system level. Init is sez-code for sez's ga402

with import ../functions;

{
  imports = useModules [

    # Asus support
    "asusctl" "supergfxctl" "radeontop"

    # Shells and Terminal emulators
    "zellij" "babashka"
    # "wezterm"

    # Multimedia
    "yewtube" "qbittorrent" "spotify" "ncspot" "yt-dlp"

    # Security
    "yubikey-manager" "thc-hydra" "burpsuite"

    # Productivity
    "ocrmypdf" "nyxt" "calibre" "zathura" "zoom-us" "thunderbird" "remarkable2-toolchain"
    "bc" "gnuplot"
    # "mathematica" "libreoffice"

    # Social and entertainment
    "discord" "qq" "tdesktop"

  ];
}
