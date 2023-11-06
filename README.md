# presez (Sez's Dotfiles)

<p align="center"><img src="https://github.com/sezryo/presez/blob/main/assets/icons/nixowo.png"></p>

## Introduction {#introduction}
NixOS is of perfect functionalities. In a reproducible paradigm, modualised frameworks are built around the system. Should users being bothered by the back-and-forth modifications and looking ups in their ricing, or just daily maintanance attempts, a better solution pipelining monads shall be introduced in some way. The NixOS internalised rolling back system enjoyers shall also expect a well-functional rolling back, and more, system working inside their concise dotfile directories. 

By modualising the dotfile flake, we are now able to describe what to use and what not to use in a sole profile file in a pre-configured modualised manner, which is also friendly to beginners. Should you assume I'm building a CLI simply integrating commands, the project actually aims to achieve something like a local version controller. Users may build various versions of profiles of configuration, which maps to the NixOS version-ised system profiles, and they can be reused and branches may be maded deviating from profiles, creating a well-founded baseground for system config hoppers.

Details of the CLI (yo) may be found in [How To Use](#how-to-use) below.

## My toolchain {#my-toolchain}
|                            | NixOS-unstable (With flakes and [flake-parts](https://github.com/hercules-ci/flake-parts))                                                                                    |
|----------------------------|:-----------------------------------------------------------------------------------------------------------:|
| **Colour Scheme**          | [Catppuccin-Frappé](https://github.com/catppuccin/catppuccin)                                               |
| **Window Manager**         | [Hyprland](https://github.com/hyprwm/Hyprland)                                                              |
| **Terminal Emulator**      | [Wezterm](https://wezfurlong.org/wezterm/), [Alacritty](https://github.com/alacritty/alacritty)             |
| **Bar**                    | [Eww](https://github.com/elkowar/eww)                                                                       |
| **Shell**                  | [Nushell (primary)](https://github.com/nushell/nushell), [Xonsh (login)](https://github.com/xonsh/xonsh)    |
| **Text Editor**            | [GNU Emacs](https://www.gnu.org/software/emacs/)                                                            |
| **Browser**                | [Firefox](www.mozilla.org/en-GB/), [Nyxt](https://nyxt.atlas.engineer/)                                     |
| **Fetch**                  | [Hyfetch](https://github.com/hykilpikonna/hyfetch)                                                          |
| **Input method framework** | [Fcitx5-Rime](https://github.com/fcitx/fcitx5-rime)                                                         |
| **File Manager**           | [LF](https://github.com/gokcehan/lf), [Dolphin](https://apps.kde.org/en-gb/dolphin/)                        |
| **Application Launcher**   | [Rofi-wayland](https://github.com/lbonn/rofi)                                                               |
| **Notification Daemon**    | [Dunst](https://github.com/dunst-project/dunst)                                                             |
| **Display Manager**        | [sddm-corners](https://github.com/aczw/sddm-theme-corners)                                                  |
| **Lock Screen**            | [swaylock-effects](https://github.com/mortie/swaylock-effects)                                              |
| **Fonts**                  | [JetBrains-mono](https://www.jetbrains.com/lp/mono/), [Nerd fonts](https://github.com/ryanoasis/nerd-fonts) |
| **English**                | [en_GB](https://www.bbc.com/culture/article/20170904-how-americanisms-are-killing-the-english-language)     |

## How to use {#how-to-use}

NOTICE: Ignore all my narcissistic words in the [Introduction](#introduction) above, currently the project is still based for my own personal use. Where I kept an attic faith following conducts for global reproduciblity, lots of configs still are in the "works on my and my neighbourhood's machines" stage, so be careful if you simply clone and build everything.

TODO: Print help message of yo here.
