{ config, pkgs, lib, ... }:

# These are modules used across all devices on home level

with import ../functions;

{
  imports = useHomeModules [

    # Toolchain for languages, n.b. only languages' modules' names are not indentical to its packages
    "agda" "coq" "purescript" "purescript" # Goodies
    "clojure" "elixir" "nix" "racket" "scheme" # Quasi-goodies
    "ruby" "rust" "tex" # Normies
    "c" "python" # Baddies

    # Essentials
    "firefox" "chromium" "vim" "emacs" "wget" "lf"

    # Utils
    "binutils" "coreutils" "cpufrequtils" "pciutils"

    # Asus support
    "asusctl" "supergfxctl" "radeontop"

    # Command line tools
    "grex" "lsd" "ripgrep" "bottom" "du-dust" "fzf" "procs" "tealdeer" "bat" "sd" "fd" "htop"
    "neofetch" "hyfetch"
    "zip" "unzip" "psmisc" "pueue"

    # Developing
    "gh" "gnumake" "tokei" "git" "nodejs-18_x" "cachix"

    # I/O
    "ffmpeg" "mesa" "mesa-demos" "vlc"
    "lm_sensors" "libinput-gestures" "bluez" "bluez-tools"

    # Shells and Terminal emulators
    "nu" "alacritty" "zoxide" "starship" "zellij" "babashka"
    # "wezrerm"

    # Productivity
    "ocrmypdf" "nyxt" "calibre" "zathura" "zoom-us" "thunderbird" "remarkable2-toolchain"
    "bc" "gnuplot" "newsflash" "okular"
    # "mathematica" "libreoffice"

    # Virtual environment
    "bottles" "qemu"

    # Controllers
    "gammastep" "brightnessctl" "pamixer" "wev" "cava"

    # Operating environment
    "hyprland" "eww" "wl-clipboard" "swaybg" "xdg-desktop-portal-wlr" "rofi" "fuzzel" "mako" "gtk4" "waybar" "grim"

    # Multimedia, social and entertainment
    "yewtube" "qbittorrent" "spotify" "ncspot" "yt-dlp" "discord" "qq" "tdesktop"

    # Security
    "yubikey-manager" "thc-hydra" "burpsuite"

    # TODO: Need to migrate these modules into nix-fashioned
    # "emacs"
  ];

}
