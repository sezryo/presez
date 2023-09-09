{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib.mine) rakeLeaves;
  modules = rakeLeaves ../../../modules;
  homeFiles = with modules.shelter; [
      
    # Essentials
    firefox chromium lf krusader socat

    # Emacs
    ispell sqlite graphviz poppler_utils

    # Command line tools
    grex lsd ripgrep bottom du-dust fzf procs tealdeer bat sd fd htop gojq jaq
    neofetch hyfetch cbonsai baobab
    zip unzip psmisc pueue

    # Developing
    tokei cachix direnv electron qt dig
    
    # Gtk
    gtk gnome-control-center gnome-tweaks networkmanagerapplet

    # I/O
    ffmpeg mesa mesa-demos vlc xvidcore
    lm_sensors libinput-gestures radeontop ventoy

    # Bluetooth
    bluez bluez-tools blueberry

    # Shells and Terminal emulators
    nu alacritty zoxide starship zellij babashka
    wezterm

    # Productivity
    ocrmypdf calibre zathura thunderbird remarkable2-toolchain
    bc gnuplot newsflash okular imagemagick dolphin
    libreoffice nyxt zoom-us
    # mathematica

    # Virtual environment
    bottles qemu virt-manager quickemu quickgui
    yuzu-early-access
    
    # Controllers
    gammastep brightnessctl playerctl wev cava

    # Wayland
    wl-clipboard wlogout swaybg swaylock

    # Desktop environment
    hyprland eww rofi fuzzel dunst grim

    # Multimedia, social and entertainment
    yewtube qbittorrent spotify yt-dlp discord qq tdesktop steam ncspot

    # Security
    yubikey thc-hydra burpsuite gpg
  ];  
  devFiles = with modules.dev; [
    # Pure
    coq.home agda.home purescript.home haskell.home nix.home
    # Lisp
    emacs.home clojure.home racket.home scheme.home
    # Others
    ocaml.home elixir.home ocaml.home ruby.home rust.home tex.home python.home typescript.home git.home
  ];

in {
  imports = homeFiles ++ devFiles;
}
