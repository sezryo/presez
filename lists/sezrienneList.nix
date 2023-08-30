{ config, pkgs, lib, ... }:

# These are modules used across all devices on home level

with import ../functions;

{
  imports = useHomeModules [

    # Toolchain for languages, n.b. only languages' modules' names are not indentical to its packages
    "LANG_agda" "LANG_coq" "LANG_purescript" "LANG_haskell" # Goodies
    "LANG_clojure" "LANG_elixir" "LANG_nix" "LANG_racket" "LANG_scheme" "LANG_ocaml" # Quasi-goodies
    "LANG_ruby" "LANG_rust" "LANG_tex" # Normies
    "LANG_c" "LANG_python" # Baddies

    # Essentials
    "firefox" "chromium" "vim" "wget" "lf" "krusader" "socat"

    # Emacs
    "emacs" "ispell" "sqlite" "graphviz" "poppler_utils"

    # Utils
    "binutils" "coreutils" "cpufrequtils" "pciutils" "findutils" "gawk"

    # Command line tools
    "grex" "lsd" "ripgrep" "bottom" "du-dust" "fzf" "procs" "tealdeer" "bat" "sd" "fd" "htop" "gojq" "jaq"
    "neofetch" "hyfetch" "cbonsai" "baobab"
    "zip" "unzip" "psmisc" "pueue"

    # Developing
    "gh" "gnumake" "tokei" "git" "nodejs-18_x" "cachix" "direnv"
    "yarn" "yarn2nix" "pnpm"
    
    # Frontend
    "electron" "qt"

    # Networking
    "dig"
    
    # Gtk
    "gtk" "gnome.gnome-control-center" "gnome.gnome-tweaks" "networkmanagerapplet"

    # I/O
    "ffmpeg" "mesa" "mesa-demos" "vlc" "xvidcore"
    "lm_sensors" "libinput-gestures" "radeontop"

    # Bluetooth
    "bluez" "bluez-tools" "blueberry"

    # Shells and Terminal emulators
    "nu" "alacritty" "zoxide" "starship" "zellij" "babashka"
    "wezterm"

    # Productivity
    "ocrmypdf" "calibre" "zathura" "thunderbird" "remarkable2-toolchain"
    "bc" "gnuplot" "newsflash" "okular" "imagemagick" "dolphin"
    "libreoffice" "nyxt" "zoom-us"
    # "mathematica"

    # Virtual environment
    "bottles" "qemu" "virt-manager" "quickemu" "quickgui" # System level configs in system/virtualisation
    "yuzu-early-access"
    
    # Controllers
    "gammastep" "brightnessctl" "playerctl" "wev" "cava"

    # Wayland
    "wl-clipboard" "wlogout" "swaybg" "swaylock"

    # Desktop environment
    "hyprland" "eww" "rofi" "fuzzel" "dunst" "grim"

    # Multimedia, social and entertainment
    "yewtube" "qbittorrent" "spotify" "yt-dlp" "discord" "qq" "tdesktop" "steam" "ncspot"

    # Security
    "yubikey-manager" "thc-hydra" "burpsuite" "gpg"

  ];

}
