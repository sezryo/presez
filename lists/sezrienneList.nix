{ config, pkgs, lib, ... }:

# These are modules used across all devices on home level

with import ../functions;

{
  imports = useHomeModules [

    # Toolchain for languages, n.b. only languages' modules' names are not indentical to its packages
    "LANG_agda" "LANG_coq" "LANG_purescript" # Goodies
    "LANG_clojure" "LANG_elixir" "LANG_nix" "LANG_racket" "LANG_scheme" # Quasi-goodies
    "LANG_ruby" "LANG_rust" "LANG_tex" # Normies
    "LANG_c" "LANG_python" # Baddies

    # Essentials
    "firefox" "chromium" "vim" "emacs" "wget" "lf" "krusader" "socat"

    # Utils
    "binutils" "coreutils" "cpufrequtils" "pciutils" "findutils" "gawk"

    # Command line tools
    "grex" "lsd" "ripgrep" "bottom" "du-dust" "fzf" "procs" "tealdeer" "bat" "sd" "fd" "htop" "gojq" "jaq"
    "neofetch" "hyfetch"
    "zip" "unzip" "psmisc" "pueue"

    # Developing
    "gh" "gnumake" "tokei" "git" "nodejs-18_x" "cachix"

    # I/O
    "ffmpeg" "mesa" "mesa-demos" "vlc"
    "lm_sensors" "libinput-gestures" "radeontop"

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
    "bottles" "qemu" "virt-manager" "quickemu" "quickgui" # System level configs in system/virtualisation

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
