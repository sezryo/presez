{ pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "/home/sezrienne/presez/signs/alacritty/init.yml" ];
    };
  };
}
