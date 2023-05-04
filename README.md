# presez (Sez's Dotfiles)

<p align="center"><img src="https://github.com/sezryo/presez/blob/main/assets/icons/nixowo.png"></p>

## My toolchain
|                            | NixOS-unstable (Wayland)                                                                                    |
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
| **File Manager**           | [LF](https://github.com/gokcehan/lf)                                                                        |
| **Application Launcher**   | [Rofi-wayland](https://github.com/lbonn/rofi)                                                               |
| **Notification Daemon**    | [Dunst](https://github.com/dunst-project/dunst)                                                             |
| **Display Manager**        | [sddm-corners](https://github.com/aczw/sddm-theme-corners)                                                  |
| **Lock Screen**            | [swaylock-effects](https://github.com/mortie/swaylock-effects)                                              |
| **Fonts**                  | [JetBrains-mono](https://www.jetbrains.com/lp/mono/), [Nerd fonts](https://github.com/ryanoasis/nerd-fonts) |
| **English**                | [en_GB](https://www.bbc.com/culture/article/20170904-how-americanisms-are-killing-the-english-language)     |

## How to use

Even if the dotfiles is designed for my private use, you may have a try on it to get some inspirations. To use the dotfiles:

1. Simply clone this repo, cd to the directory, and you may change the `sezrienne` block in `flake.nix` and `homes/sezrienne/` to customise your own user usage.

2. Run `sudo nixos-rebuild switch --flake "path:./#YOUR_USER_NAME"` and all set. You may use my shell rebuild function shorthands after the first build and enter the Nushell, usage is available by running `help jr`

3. Notice that my daily machine is ASUS GA402 with an APU and a dedicated AMD GPU, thus my dotfiles are designed for them, you may need change files catering to your own usage in `system/`.
