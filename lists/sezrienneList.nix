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
    "firefox" "chromium" "vim" "emacs" "wget" "lf" "socat"

    # Utils
    "binutils" "coreutils" "cpufrequtils" "pciutils" "findutils" "gawk"

    # Asus support
    "asusctl" "supergfxctl" "radeontop"

    # Command line tools
    "grex" "lsd" "ripgrep" "bottom" "du-dust" "fzf" "procs" "tealdeer" "bat" "sd" "fd" "htop" "gojq" "jaq"
    "neofetch" "hyfetch"
    "zip" "unzip" "psmisc" "pueue"

    # Developing
    "gh" "gnumake" "tokei" "git" "nodejs-18_x" "cachix"

    # I/O
    "ffmpeg" "mesa" "mesa-demos" "vlc"
    "lm_sensors" "libinput-gestures"

    # Bluetooth
    "bluez" "bluez-tools" "blueberry"

    # Shells and Terminal emulators
    "nu" "alacritty" "zoxide" "starship" "zellij" "babashka"
    "wezterm"

    # Productivity
    "ocrmypdf" "nyxt" "calibre" "zathura" "zoom-us" "thunderbird" "remarkable2-toolchain"
    "bc" "gnuplot" "newsflash" "okular" "imagemagick"
    # "mathematica" "libreoffice"

    # Virtual environment
    "bottles" "qemu"

    # Controllers
    "gammastep" "brightnessctl" "playerctl" "wev" "cava"

    # Wayland
    "wl-clipboard" "wlogout" "swaybg" "gtk4"

    # Desktop environment
    "hyprland" "eww"  "rofi" "fuzzel" "dunst" "grim" "gnome.gnome-control-center"

    # Multimedia, social and entertainment
    "yewtube" "qbittorrent" "spotify" "ncspot" "yt-dlp" "discord" "qq" "tdesktop"

    # Security
    "yubikey-manager" "thc-hydra" "burpsuite"

  ];

}
