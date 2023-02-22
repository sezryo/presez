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

    # Command line tools
    "grex" "lsd" "ripgrep" "bottom" "du-dust" "fzf" "procs" "tealdeer" "bat" "sd" "fd"
    "neofetch" "hyfetch"
    "zip" "unzip" "psmisc"

    # Developing
    "gh" "gnumake" "tokei" "git" "nodejs-18_x" "cachix"

    # I/O
    "ffmpeg" "mesa" "mesa-demos" "vlc"
    "lm_sensors" "libinput-gestures" "bluez" "bluez-tools"

    # Shells and Terminal emulators
    "nu" "alacritty" "zoxide" "starship" "okular"

    # Virtual environment
    "bottles" "qemu"

    # Controllers
    "gammastep" "brightnessctl" "pamixer" "wev" "cava"

    # Operating environment
    "eww" "wl-clipboard" "swaybg" "xdg-desktop-portal-wlr" "rofi" "fuzzel" "mako" "gtk4" "waybar" "grim"

    # TODO: Need to migrate these modules into nix-fashioned
    # "emacs" "hyprland"
  ] ++ [ /home/sezrienne/presez/modules/hyprland/home.nix ];

}
